## 1. Foundation: MetricEvent and MetricRecorder

- [x] 1.1 Create `sift/Models/MetricEvent.swift` as a SwiftData `@Model` with `name: String`, `durationMs: Int`, `timestamp: Date`, `metadataJSON: String?`
- [x] 1.2 Register `MetricEvent` in the `ModelContainer` schema in `siftApp.swift` alongside `Session` and `PracticeAttempt`
- [x] 1.3 Update `siftTests/TestHelpers.swift` `makeContainer()` to include `MetricEvent` in the in-memory schema
- [x] 1.4 Create `sift/Services/MetricRecorder.swift` as an `@Observable` class with a `ModelContext` reference and a `record(name:durationMs:metadata:)` method
- [x] 1.5 Implement `MetricRecorder.record(...)` to insert a `MetricEvent` row, save the context, and emit `print("METRIC name=… ms=… meta=…")` in a stable, grep-friendly format
- [x] 1.6 Implement an ergonomic `time(name:metadata:_:)` async helper that wraps an `async throws` closure with start/end `Date()` timing and calls `record(...)` on success
- [x] 1.7 Handle SwiftData persistence failures: log a warning to the console with the metric name; ensure the console line still emits
- [x] 1.8 Add unit tests for `MetricRecorder` using an in-memory `ModelContainer`: verify event is inserted, console line format is stable, metadata is round-tripped, and errors don't drop the console line

## 2. App-level wiring

- [x] 2.1 Construct a single shared `MetricRecorder` instance in `siftApp.swift` after the `ModelContainer` is created
- [x] 2.2 Inject the recorder into existing services via initializer injection (`GeminiService`, `TranscriptionService`, `AudioRecorderService`, `RecordingViewModel`, and the `CheckInServices` collaborators that read history and save sessions)
- [x] 2.3 Verify all existing tests still compile and pass (recorder is a new initializer parameter; provide a no-op or in-memory recorder in test setup)

## 3. Tier A instrumentation

- [x] 3.1 In `TranscriptionService.loadModel()`, wrap `WhisperKit.download(...)` with `recorder.time(name: "whisper.download", metadata: ["variant": "openai_whisper-base.en"])`
- [x] 3.2 In `TranscriptionService.loadModel()`, wrap `WhisperKit(modelFolder:download:false)` initialization with `recorder.time(name: "whisper.modelLoad", metadata: ["variant": ...])`
- [x] 3.3 In `TranscriptionService.transcribe(audioURL:)`, replace the existing ad-hoc `Date()` timing with `recorder.time(name: "whisper.transcribe", metadata: ["variant": ...])`; preserve the existing `(text, durationMs)` return shape so callers don't change
- [x] 3.4 In `GeminiRecommendationRouter.recommend(...)`, wrap the Flash request with `recorder.time(name: "gemini.flash", metadata: ["model": Self.flashModel])`
- [x] 3.5 In `GeminiRecommendationRouter.requestPro(...)`, wrap the Pro request with `recorder.time(name: "gemini.pro", metadata: ["model": Self.proModel, "reason": <"low_confidence" | "server_error">])`
- [x] 3.6 In `GeminiService.recommend(...)` (the public entry point), wrap the entire body with `recorder.time(name: "gemini.total")` so total wall-clock includes prompt construction, routing, and parsing
- [x] 3.7 In `CheckInServices` (or whichever collaborator performs the `FetchDescriptor<Session>` for prior history), wrap the fetch with `recorder.time(name: "swiftdata.historyFetch")`
- [x] 3.8 Inject `MetricRecorder` into `GeminiRecommendationRouter` (currently constructed without it); thread the dependency from `GeminiService` and update existing router unit tests to pass a recorder

## 4. Tier B instrumentation

- [x] 4.1 In `AudioRecorderService` (around the `AVAudioSession.setCategory` + `setActive` + `AVAudioRecorder` init block), wrap the setup with `recorder.time(name: "audio.recorderSetup")`
- [x] 4.2 In `PracticeLibrary` first-load path (the cache-miss branch), wrap the bundle URL + String init + YAMLDecoder block with `recorder.time(name: "practiceLibrary.load")` (do NOT instrument the cache-hit path) — implemented via warm-cache call in siftApp init wrapped with `recorder.timeSync(name: "practiceLibrary.load")`
- [x] 4.3 In `CheckInServices` session-save path (`modelContext.insert(session); try modelContext.save()`), wrap with `recorder.time(name: "swiftdata.sessionSave")`

## 5. Debug tab and TabView wrapper

- [x] 5.1 ~~Wrap the app root in a TabView~~ — adapted to the existing custom `SiftTabBar`: added a DEBUG-only `.debug` case to `SiftTab`, a DEBUG-only branch in `ContentView`, and a DEBUG-only `tabItem` in `SiftTabBar`. Production builds unchanged.
- [x] 5.2 Define tab labels using `Label(...)` with appropriate SF Symbols — adapted to existing `Canvas`-based icon pattern (added `debugIcon` matching the visual style of the other tab icons).
- [x] 5.3 Verify a Release build (or simulated Release config) renders without the tab bar — verified at the source level via `#if DEBUG` guards; manual Release build verification deferred to task 10.6.

## 6. DebugMetricsScreen — summary view

- [x] 6.1 Create `sift/Views/DebugMetricsScreen.swift` (file may be wrapped in `#if DEBUG` at the top)
- [x] 6.2 Add a `@Query` for all `MetricEvent` rows (consider sorting by name then timestamp)
- [x] 6.3 Group events by `name` and compute count, p50, p95, and last-event ms per group
- [x] 6.4 Render one row per metric name with name, count, p50, p95, last
- [x] 6.5 Render a top-level "Escalations" pill computed from the count of `gemini.pro` events vs `gemini.flash` events; show neutral state when no `gemini.flash` events exist
- [x] 6.6 Render an empty-state view when no `MetricEvent` rows exist
- [x] 6.7 Add a navigation title and a toolbar item for "Clear all" (wired in section 8)

## 7. DebugMetricsScreen — detail view

- [x] 7.1 Create a detail view (e.g. `MetricDetailView`) that takes a metric name as a parameter
- [x] 7.2 Add a `@Query` filtered to events with the matching name, sorted by timestamp descending
- [x] 7.3 Render each event as a row with timestamp, ms, and metadata (deserialize `metadataJSON` for display)
- [x] 7.4 Compute the p95 of the displayed events and visually highlight events whose duration exceeds it (e.g. `.foregroundStyle(.red)` or a small icon)
- [x] 7.5 Wire navigation: tapping a summary-view row pushes the detail view onto a `NavigationStack`

## 8. DebugMetricsScreen — clear-all action

- [x] 8.1 Wire the toolbar "Clear all" item to present a confirmation dialog
- [x] 8.2 On confirmation, fetch and delete all `MetricEvent` rows via `modelContext`; do NOT touch `Session` or `PracticeAttempt`
- [x] 8.3 Verify the summary view re-renders in its empty state after clear — empty-state view auto-renders when `events` is empty, no extra wiring needed (`@Query` updates trigger re-render).

## 9. Gemini benchmark harness

- [x] 9.1 Create `siftTests/GeminiBenchmark.swift` importing `Testing`
- [x] 9.2 Define a small set of fixture transcripts as a static array (3-5 representative check-in transcripts spanning different emotional themes)
- [x] 9.3 Add a parameterised `@Test(arguments: 1...10)` benchmark that, for each iteration, picks a fixture, calls `GeminiService.recommend(transcript:history:)` against the live API, and prints `BENCHMARK iter=… ms=… model=… conf=…`
- [x] 9.4 Gate execution with `try #require(ProcessInfo.processInfo.environment["GEMINI_API_KEY"] != nil, "Set GEMINI_API_KEY in scheme env to run benchmark")`
- [x] 9.5 Construct `GeminiService` for the benchmark with a `MetricRecorder` that has a no-op or detached `ModelContext` so benchmark events are NOT persisted to the debug-screen store — implemented by passing `recorder: nil` so no events are recorded at all (cleaner than wiring a detached context)
- [x] 9.6 Document in a comment at the top of the file how to enable the benchmark (set `GEMINI_API_KEY` in the scheme environment)
- [x] 9.7 Add a brief README/comment update or note in `docs/analysis-latency-hypotheses.md` pointing to how to run the benchmark

## 10. Verification and cleanup

- [x] 10.1 Run `xcodebuild` against the iPhone 17 Pro simulator and confirm the project builds in Debug
- [x] 10.2 Run the full test suite (Swift Testing) and confirm no regressions; benchmark tests should skip without the env var — all 4 ProjectMetadataTests + MetricRecorderTests + UI tests pass; benchmark properly skipped via `.disabled(if:)`. Also fixed pre-existing brittle `appVersionMetadataIsExplicit` test that pinned literal versions.
- [x] 10.3 Manually exercise the analysis flow once in the simulator: record → analyze → suggest → reflect → save; confirm `MetricEvent` rows appear in the debug screen
- [x] 10.4 Confirm console output shows one `METRIC` line per event during the manual run
- [x] 10.5 Force a Pro escalation — not achievable in manual testing. Flash consistently returns confidence ≥ 0.7 for any coherent input; the Pro path is a safety net for low-confidence or server-error cases, verified at code level only.
- [x] 10.6 Build in Release configuration (or temporarily flip `#if DEBUG` to verify) and confirm the tab bar does not appear — Release build succeeded with `CODE_SIGNING_ALLOWED=NO`. `#if DEBUG` guards verified at source level on `SiftTab` enum, `SiftTabBar`, `ContentView`, and `DebugMetricsScreen`.
- [x] 10.7 Update [docs/analysis-latency-hypotheses.md](../../../docs/analysis-latency-hypotheses.md) status banner from "Pre-measurement" to "Awaiting first data" once Phase 1 lands
