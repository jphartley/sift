## ADDED Requirements

### Requirement: System records named timing measurements for instrumented operations

The system SHALL provide a `MetricRecorder` capability that captures named timing events. Each event SHALL include a metric name (string identifier in `domain.operation` form), a duration in milliseconds, a timestamp, and optional metadata as a JSON-serializable dictionary. The recorder SHALL persist each event to a SwiftData `MetricEvent` entity and SHALL emit a single `METRIC name=… ms=… meta=…` line to the console for each event. Recording behavior SHALL be active in all build configurations (Debug and Release).

#### Scenario: Operation completes and recorder captures the event

- **WHEN** an instrumented operation completes
- **THEN** the system SHALL persist a `MetricEvent` with the operation's name, measured duration in milliseconds, current timestamp, and any metadata provided by the call site
- **THEN** the system SHALL emit one `METRIC` line to the console containing the same fields in a stable, grep-friendly format

#### Scenario: Operation throws or fails partway through

- **WHEN** an instrumented operation throws before completing
- **THEN** the system SHALL NOT record a successful timing event for that attempt
- **THEN** the system MAY record an explicit failure event tagged in metadata if the call site chooses to do so

#### Scenario: Recorder cannot persist a captured event

- **WHEN** SwiftData persistence of a `MetricEvent` fails for any reason
- **THEN** the system SHALL still emit the console line for that event
- **THEN** the system SHALL log a warning to the console identifying the metric name and the persistence failure

### Requirement: System persists metric events as a SwiftData entity

The system SHALL define a `MetricEvent` SwiftData model with at minimum: a `name` (`String`), a `durationMs` (`Int`), a `timestamp` (`Date`), and optional metadata serialized as a JSON `String`. The `MetricEvent` entity SHALL be additive to the existing `ModelContainer` schema and SHALL NOT modify the existing `Session` or `PracticeAttempt` models.

#### Scenario: App launches with the new schema

- **WHEN** the app launches after this change is deployed
- **THEN** the system SHALL register `MetricEvent` alongside `Session` and `PracticeAttempt` in the SwiftData container schema
- **THEN** existing `Session` and `PracticeAttempt` rows SHALL remain unchanged and accessible

#### Scenario: Metric events accumulate across sessions

- **WHEN** the user closes and reopens the app
- **THEN** previously recorded `MetricEvent` rows SHALL remain queryable

### Requirement: System instruments Tier A operations on the analysis-flow critical path

The system SHALL record timing events for the following operations using the metric names listed:

- `whisper.download` for the WhisperKit model download phase
- `whisper.modelLoad` for the WhisperKit model-folder-to-memory load phase
- `whisper.transcribe` for the WhisperKit transcribe call (replacing the existing ad-hoc timing in `TranscriptionService.transcribe`)
- `gemini.flash` for the Flash-model recommendation request
- `gemini.pro` for the Pro-model recommendation request, only when escalation occurs
- `gemini.total` for the entire `GeminiService.recommend(...)` wall-clock including parsing and routing
- `swiftdata.historyFetch` for the SwiftData fetch of prior sessions used to build the recommendation prompt

#### Scenario: A check-in produces a Flash-only recommendation

- **WHEN** the user completes a recording and the Flash response has confidence ≥ 0.7
- **THEN** the system SHALL record `whisper.transcribe`, `swiftdata.historyFetch`, `gemini.flash`, and `gemini.total` events
- **THEN** the system SHALL NOT record a `gemini.pro` event

#### Scenario: A check-in escalates to Pro

- **WHEN** the user completes a recording and the Flash response has confidence < 0.7
- **THEN** the system SHALL record both `gemini.flash` and `gemini.pro` events for the same session
- **THEN** the `gemini.total` value SHALL be greater than or equal to `gemini.flash + gemini.pro` for that session

#### Scenario: Cold launch downloads and loads the WhisperKit model

- **WHEN** the app launches with no cached WhisperKit model
- **THEN** the system SHALL record both `whisper.download` (with non-trivial duration) and `whisper.modelLoad` events on first call to `loadModel()`

#### Scenario: Cold launch with cached model

- **WHEN** the app launches with a cached WhisperKit model
- **THEN** the system SHALL still record `whisper.download` (with near-zero duration) and `whisper.modelLoad` events

### Requirement: System instruments Tier B operations adjacent to the critical path

The system SHALL record timing events for the following operations using the metric names listed:

- `audio.recorderSetup` for `AVAudioSession` configuration and `AVAudioRecorder` initialization triggered by the user tapping record
- `practiceLibrary.load` for the first read of the YAML practice library from the bundle
- `swiftdata.sessionSave` for persisting a completed `Session` to SwiftData

#### Scenario: User taps record and the audio session is configured

- **WHEN** the user taps record and the audio recorder service initializes its `AVAudioSession` and `AVAudioRecorder`
- **THEN** the system SHALL record one `audio.recorderSetup` event with the duration of the setup block

#### Scenario: First access to the practice library after launch

- **WHEN** any caller requests the parsed practice library and the library has not yet been loaded
- **THEN** the system SHALL record one `practiceLibrary.load` event with the duration of the bundle read and YAML parse

#### Scenario: User completes a session and it is persisted

- **WHEN** the system saves a completed `Session` (with any attached `PracticeAttempt` rows) to SwiftData
- **THEN** the system SHALL record one `swiftdata.sessionSave` event

### Requirement: WhisperKit metric events are tagged with model variant

The system SHALL include the WhisperKit model variant (e.g. `openai_whisper-base.en`) in the metadata of `whisper.download`, `whisper.modelLoad`, and `whisper.transcribe` events, so that future analysis across multiple variants can distinguish them by querying historical events.

#### Scenario: WhisperKit operation completes with default variant

- **WHEN** any WhisperKit timing event is recorded
- **THEN** the event metadata SHALL contain a `variant` key whose value is the WhisperKit model variant identifier in use at the time of the call

### Requirement: Gemini total measurement wraps the entire recommendation call

The system SHALL measure `gemini.total` as the wall-clock duration from the start of `GeminiService.recommend(...)` to its return, including all internal routing logic, parsing, and any escalation request. Per-call metrics (`gemini.flash`, `gemini.pro`) SHALL measure only their respective network requests, so that the difference between `gemini.total` and the sum of per-call metrics reveals routing and parsing overhead.

#### Scenario: Flash-only recommendation completes

- **WHEN** a recommendation completes with no escalation
- **THEN** the recorded `gemini.total` SHALL be greater than or equal to the recorded `gemini.flash` for that session
- **THEN** the difference SHALL represent prompt construction, parsing, and routing overhead

#### Scenario: Recommendation escalates to Pro

- **WHEN** a recommendation escalates from Flash to Pro
- **THEN** the recorded `gemini.total` SHALL be greater than or equal to the sum of `gemini.flash` and `gemini.pro` for that session

### Requirement: Production builds remain visually unchanged

The system SHALL ensure that Release-configuration builds render the existing app navigation and screens unchanged by this change. Console-line emission MAY occur in Release builds; the debug-only metrics screen and the conditional `TabView` wrapper SHALL be excluded from Release builds via `#if DEBUG`.

#### Scenario: Release build launches

- **WHEN** the app is built and launched in Release configuration
- **THEN** the user SHALL see the same root navigation as before this change (no tab bar, no debug tab, no debug screen)
- **THEN** the system MAY still emit `METRIC` console lines

#### Scenario: Debug build launches

- **WHEN** the app is built and launched in Debug configuration
- **THEN** the system SHALL render a `TabView` containing the main app and a Debug tab
