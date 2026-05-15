## Context

The Sift app's analysis flow (audio → Whisper → Gemini → suggestions) currently has only one timing measurement: `TranscriptionService.transcribe` records the WhisperKit transcribe call duration. Everything else — WhisperKit model load (separate from download, separate from transcribe), Gemini Flash, Gemini Pro escalation, total Gemini wall-clock, SwiftData fetches, audio recorder setup — is unmeasured. The user reports the analysis phase feels like ~30 seconds, but cannot say where the time goes. Before any optimization work, we need durable measurement.

The exploration that produced this change documented hypotheses, an experiment matrix, and decision rules in [docs/analysis-latency-hypotheses.md](../../../docs/analysis-latency-hypotheses.md). This change implements the measurement infrastructure those experiments will rely on.

## Goals / Non-Goals

**Goals:**
- Capture timing data for ten operations across the analysis-flow pipeline (Tier A + Tier B in the proposal).
- Persist timings to a SwiftData entity for cross-launch analysis and stat computation.
- Emit a grep-able console line per event for live debugging.
- Provide a developer-only debug screen with summary stats (count / p50 / p95 / last) and per-metric drill-down.
- Surface escalation rate (Flash → Pro) prominently as the most diagnostic single number for the stated problem.
- Provide a Swift Testing benchmark harness for repeatable Gemini measurements with stable inputs.
- Forward-compatibility: tag WhisperKit events with model variant so future variant experiments can be analyzed by reading historical metric data.
- Keep production builds (Release config) visually identical.

**Non-Goals:**
- Phase 3 optimization experiments (deferred — captured in the hypotheses doc).
- Tier C measurements: app-launch time, HistoryScreen `@Query` refresh.
- Charts, sparklines, date-range filtering, or window-diff on the debug screen.
- JSONL file persistence (export button is a future add).
- Real-device / TestFlight measurement workflow (DEBUG-only for v1).
- Modifying the existing `Session` or `PracticeAttempt` SwiftData models.
- Streaming Gemini responses or any UX change to the analysis flow.

## Decisions

### D1. Persistence: SwiftData `MetricEvent` entity + console line per event

**Decision:** Store metric events in a new `MetricEvent` SwiftData entity. Also emit a `METRIC name=… ms=… meta=…` line to the console for every event. The console line is the live-debugging surface; the SwiftData entity is the cross-launch analysis surface.

**Alternatives considered:**
- **In-memory only.** Rejected: loses data on every app restart, defeats "series of measurements" goal.
- **Append-only JSONL file in app support directory.** Considered. Less convenient for in-app stat computation. Easier to copy off device for external analysis. Could be added later as an "Export as JSONL" button without changing the underlying model.
- **UserDefaults.** Not suitable for >100 entries.

**Rationale:** SwiftData is the existing persistence story in the app, so no new conceptual machinery. Adding an entity (vs modifying an existing one) is migration-free. In-app stat computation becomes trivial via `@Query` + `reduce`.

### D2. New SwiftData entity, not a change to `Session`

**Decision:** `MetricEvent` is a separate entity. `Session` keeps `transcriptionDurationMs`, `geminiModelUsed`, `geminiConfidence` exactly as they are. Per-session timing data is reachable by joining on timestamp/correlation if needed later, but not modeled as a relationship in v1.

**Rationale:** Keeps the production data model stable. Avoids any migration risk on the user-facing entity. Metric events have a different lifecycle (debugging, transient) than session data (durable, user-facing).

### D3. Metric naming: dot-separated string identifiers

**Decision:** Names are `domain.operation` strings, e.g. `whisper.download`, `gemini.flash`, `swiftdata.historyFetch`. Stored as `String` on `MetricEvent`, not as an enum.

**Alternatives considered:**
- **Swift enum with associated metadata.** Rejected for v1: every new metric site requires a code change to the enum. Strings are cheaper to add and tolerate experimentation.

**Rationale:** Optimizing for ergonomics during measurement work, not for compile-time exhaustiveness. The set of metric names is small enough that typos will surface immediately on the debug screen.

### D4. WhisperKit timing: two phases, both tagged with model variant

**Decision:** Wrap `WhisperKit.download(...)` as `whisper.download` and `WhisperKit(modelFolder:download:false)` as `whisper.modelLoad`. Both events carry `{"variant": "openai_whisper-base.en"}` in metadata.

**Rationale:** The WhisperKit API already splits these cleanly, so no cache-detection logic is needed. A near-zero `whisper.download` value naturally signals "model was already cached." The variant tag is forward-compatible with the obvious "would `tiny.en` be faster?" experiment without requiring schema changes.

### D5. `gemini.total` wraps the entire `recommend()` call (network + parse + routing)

**Decision:** `gemini.total` is measured from the start of `GeminiService.recommend(...)` to its return. `gemini.flash` and `gemini.pro` measure only their respective `requester.request(...)` calls. The difference (`total - flash - (pro ?? 0)`) reveals parser and routing overhead.

**Rationale:** "Total" should match what the user feels — wall-clock from `.analyzing` start to `.suggesting` ready. Per-call metrics give us the breakdown to investigate where the time inside `total` goes.

### D6. Debug entry: `#if DEBUG`-conditional `TabView` wrapping the app root

**Decision:** In the app entry point, wrap the existing root view in a `#if DEBUG` block that produces a `TabView` with the main app as one tab and a Debug tab (containing `DebugMetricsScreen`) as another. Release builds render the existing root unchanged.

**Alternatives considered:**
- **Long-press / shake / triple-tap gesture.** Zero UI impact but easy to forget exists.
- **Toolbar icon in HistoryScreen.** Discoverable but lives in only one place.
- **Settings screen with debug row.** No settings screen exists — would require building one.

**Rationale:** Future debug tools (variant switcher, prompt tweaker, experiment toggles) get a natural home next to metrics. Production untouched.

### D7. Debug screen: two-view design (summary + per-metric detail)

**Decision:** Summary view lists each metric name with count / p50 / p95 / last. A top-level pill shows escalation rate ("Escalations: N/M (X%)"). Tapping a row navigates to a detail view listing raw events for that metric (timestamp, ms, metadata) with outliers highlighted.

**Outlier highlight rule:** an event is highlighted "slow" if its duration exceeds the p95 of its metric over the recent buffer.

**Rationale:** The two-view structure separates "is anything broken right now?" (summary) from "show me the slow runs" (detail). The escalation rate is called out explicitly because it's the single most diagnostic number for the original problem.

### D8. Active harness: Swift Testing, opt-in via `GEMINI_API_KEY`

**Decision:** A test file `siftTests/GeminiBenchmark.swift` uses Swift Testing's `@Test(arguments:)` parameterization to run `GeminiService.recommend(...)` N times against a small set of fixture transcripts. Tests `try #require(ProcessInfo.processInfo.environment["GEMINI_API_KEY"] != nil)` and skip otherwise. Output is `BENCHMARK iter=N ms=… model=… conf=…` lines parseable by tooling.

**Rationale:** Swift Testing is the framework already in use ([siftTests/ProjectMetadataTests.swift](../../../siftTests/ProjectMetadataTests.swift) imports `Testing`, not `XCTest`). Env-var gating ensures CI doesn't burn API credits and that local runs are explicit.

### D9. `MetricRecorder` lifecycle: `@Environment`-injected

**Decision:** `MetricRecorder` is an `@Observable` class injected via SwiftUI `@Environment`, with a single shared instance constructed in `siftApp` and threaded into services that need it (`GeminiService`, `TranscriptionService`, `AudioRecorderService`, etc.) via initializer injection.

**Alternatives considered:**
- **Static singleton.** Simpler but harder to substitute in tests and harder to disable for benchmark runs.
- **Per-call passing.** Too verbose for ten instrumentation sites.

**Rationale:** Mirrors the existing pattern in the app (services are constructed in `siftApp` and passed down). Tests can construct a no-op or buffer-only recorder.

### D10. Console emission stays on in Release builds

**Decision:** The `MetricRecorder` emits its `METRIC ...` console line in all build configurations. Only the debug **screen** is `#if DEBUG`-gated.

**Rationale:** Console output is invisible to end users, costs essentially nothing, and means TestFlight/device measurement runs (when we eventually do them) can capture data via Console.app without rebuilding.

## Risks / Trade-offs

- **Risk: SwiftData write on every metric event adds I/O on the critical path.** → Mitigation: writes are async and batched implicitly by SwiftData's `ModelContext.save()` cadence. If profiling shows this introduces noticeable overhead (>5ms per event), batch explicitly with a flush every N events or every M seconds.
- **Risk: `MetricEvent` table grows unbounded over weeks of debug-build use.** → Mitigation: `DebugMetricsScreen` includes a "Clear all" action. Document the manual cleanup. Add automatic rotation (e.g. cap at last 10k events) only if it becomes a real problem.
- **Risk: `MetricRecorder` capture errors (e.g. invalid metadata) silently swallow real signals.** → Mitigation: any encoding failure logs a console warning with the metric name; debug screen surfaces a "recorder errors" count if non-zero.
- **Risk: Console emission in Release builds leaks information.** → Mitigation: metric names and durations contain no user content (no transcripts, no recommendations). Metadata fields are explicitly numeric/categorical (model name, variant, confidence). Reviewed per-site at instrumentation time.
- **Trade-off: Adding a `TabView` in DEBUG builds means the dev experience differs from production.** → Accepted: the convenience of always-visible debug tooling outweighs the configuration drift.
- **Trade-off: Including the harness in Phase 1 burns Gemini credits during dev.** → Accepted: harness is opt-in via env var, never runs by default.
- **Trade-off: WhisperKit model variant is currently hard-coded; tagging metric events with it adds slight indirection.** → Accepted: the variant constant lives in `TranscriptionService` and can be referenced when constructing the metric event.

## Migration Plan

This change is purely additive and DEBUG-gated for UI:

1. Adding `MetricEvent` to the `ModelContainer` schema is a SwiftData additive migration — no data transformation needed for existing `Session`/`PracticeAttempt` rows.
2. The `#if DEBUG TabView` wrap means Release builds compiled before and after this change render identically.
3. Console line emission is purely additive and harmless if observed.
4. No external dependency changes, no API contract changes, no user-facing flow changes.

Rollback: revert the change. No data migration required (the `MetricEvent` table simply becomes orphaned and is dropped when SwiftData re-derives the schema from the smaller model set).

## Open Questions

- **Should `MetricEvent` rows be cleared automatically beyond a cap?** Current plan: manual "Clear all" only. Revisit if real usage shows the table getting unwieldy.
- **Should the harness include Whisper benchmarking too?** Out of scope per scoping conversation — Whisper benchmarking would require audio fixtures and isn't worth it for v1. Re-open if Whisper turns out to be a primary culprit in the data.
- **What threshold defines "slow" for outlier highlighting in detail view — p95 of recent events, or hard-coded per-metric thresholds?** Current plan: p95-of-recent. Cheap to swap to hard-coded later if the dynamic threshold proves noisy when the buffer is small.
- **Should the benchmark file emit results to the same `MetricEvent` store, or only to its own console output?** Current plan: console only. Mixing benchmark events with real-session events would skew the debug screen's percentiles. Tag separately if we ever want them in the same view.
