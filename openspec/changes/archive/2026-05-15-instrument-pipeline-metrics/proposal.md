## Why

The user-perceived "analysis phase" — from `.analyzing` to `.suggesting` — feels like ~30 seconds in normal use, well above any reasonable budget for a single Gemini Flash call. We have no instrumentation on the Gemini path, no instrumentation on WhisperKit model load (only on transcribe), and no easy way to look at recent timings without reading raw Xcode console scrollback. Without measurement, every optimization attempt would be guesswork. This change adds the instrumentation needed to answer "where does the time actually go?" before any Phase 3 optimization work begins. Companion document: [docs/analysis-latency-hypotheses.md](../../../docs/analysis-latency-hypotheses.md).

## What Changes

- Add a `MetricRecorder` that captures named timing events with metadata, persists them to SwiftData, and emits a structured `METRIC ...` line to the console for each event.
- Add a `MetricEvent` SwiftData entity (new entity, no change to existing `Session`/`PracticeAttempt` models) — stores name, durationMs, timestamp, and JSON metadata.
- Instrument ten operations across the analysis-flow pipeline:
  - **Tier A (analysis story):** `whisper.download`, `whisper.modelLoad`, `gemini.flash`, `gemini.pro`, `gemini.total`, `swiftdata.historyFetch`, plus routing the existing `whisper.transcribe` timing through the new recorder.
  - **Tier B (adjacent path):** `audio.recorderSetup`, `practiceLibrary.load`, `swiftdata.sessionSave`.
- Wrap the app root in a `#if DEBUG`-conditional `TabView`, adding a "Debug" tab that hosts a metrics screen. Production builds (Release config) remain visually identical.
- Add a `DebugMetricsScreen` with a summary view (per-metric count / p50 / p95 / last value, plus a top-level "Escalations: N/M (X%)" pill) and a per-metric detail view (raw events, timestamps, outlier highlighting).
- Add a Swift Testing benchmark file in `siftTests/` that calls `GeminiService.recommend(...)` against the live API, parameterised over iterations and a small fixture transcript set. Skipped by default; enabled via the `GEMINI_API_KEY` environment variable in the scheme.
- Tag WhisperKit metric events with the model variant in metadata for forward-compatibility with variant experiments.

## Capabilities

### New Capabilities
- `pipeline-metrics`: Recording, persistence, and console emission of named timing measurements with metadata for key operations across the audio → transcribe → analyze pipeline.
- `debug-metrics-screen`: Developer-only debug UI (gated by `#if DEBUG`) that displays recorded metrics with summary statistics, drill-down detail, and outlier highlighting.
- `gemini-benchmark-harness`: Repeatable Swift Testing benchmark that exercises the Gemini recommendation path against the live API with stable fixture inputs, gated by an environment variable.

### Modified Capabilities
<!-- None. Instrumentation is additive at the implementation level; no existing
     spec-level requirements change. The new `MetricEvent` entity is additive
     and does not alter existing `Session` or `PracticeAttempt` schemas. -->

## Impact

- **New code:** `Services/MetricRecorder.swift`, `Models/MetricEvent.swift`, `Views/DebugMetricsScreen.swift` (DEBUG only), `siftTests/GeminiBenchmark.swift`, fixture transcripts.
- **Modified code:** `TranscriptionService` (split download/modelLoad timing, route transcribe through recorder), `GeminiRecommendationRouter` (time flash/pro/total), `GeminiService` (inject recorder), `CheckInServices` (time history fetch + session save), `AudioRecorderService` (time recorder setup), `PracticeLibrary` (time first load), `siftApp` (conditional TabView + register `MetricEvent` in `ModelContainer` schema), `RecordingViewModel` (pass recorder through to services).
- **No production-build behavior change.** Console log lines will appear in Release builds (the recorder runs in all configurations), but the debug tab is `#if DEBUG`-only.
- **SwiftData schema change:** Adds `MetricEvent` entity. Additive — no migration impact on existing `Session`/`PracticeAttempt` data.
- **Dependencies:** No new third-party packages. Uses existing WhisperKit, GoogleGenerativeAI, SwiftData, Swift Testing.
- **API cost:** Running the benchmark consumes Gemini API credits per iteration. Default behavior is opt-in via env var, so no involuntary cost.
