## Context

Recent benchmarking of Gemini Flash shows the analysis phase is consistently slow even without Pro escalation: roughly 7.6s minimum, 8.5s median, and 10.2s maximum across 20 runs, with confidence high enough that the Flash-only path stayed in play throughout. That makes the current bottleneck look like the baseline Flash request, not the escalation threshold.

The current codebase already has a clean recommendation boundary, prompt construction, and metric collection. What it does not yet have is a way to turn individual latency hypotheses on and off independently while preserving a stable baseline. This change adds that control plane so we can test one lever at a time and keep attribution clean.

## Goals / Non-Goals

**Goals:**
- Add runtime-controlled experiment flags for analysis-phase latency work.
- Keep the current behavior as the default when no experiments are enabled.
- Make experiment combinations deterministic and observable in metrics.
- Allow the team to ship and validate individual latency slices one by one.
- Keep debug metrics readable by default while still exposing the experiment switch panel.

**Non-Goals:**
- Do not change the product contract for the default path.
- Do not add a remote configuration service.
- Do not rework WhisperKit in this change; the benchmark points at Gemini Flash first.
- Do not build a user-facing settings experience for these flags.
- Do not implement streaming, context caching, or speculative parallelization in this change.

## Decisions

### Use a runtime flag store rather than build-time switches
Feature flags should live in a runtime-controlled store so we can change them without rebuilding and compare combinations on the same app binary. A build-time `#if` approach is faster to wire up, but it would force a rebuild for every slice and make side-by-side benchmarking awkward.

### Represent experiments as independent flags, not a single mode enum
Each latency hypothesis should be toggleable on its own. A single “latency mode” enum would collapse unrelated levers into bundles and make it hard to isolate which change actually helped. Independent flags make the rollout order explicit and keep experiments composable.

The experiment set for this change is limited to Flash model variant, response schema strictness, prompt/context trimming, output token budget, confidence threshold, and disabling escalation. Streaming, context caching, and speculative parallelization are deliberately left for future changes because they alter user experience, API cost, or request orchestration more materially.

### Inject a snapshot of the active flags into the analysis request path
The Gemini request path should read a single flag snapshot at the start of a check-in and pass it through the collaborators that need it. This keeps the behavior deterministic for one request, avoids hidden global state, and makes the tests straightforward.

### Tag metrics with the active experiment state
Timing samples should carry the active flag set in a compact form. This is cheaper than expanding the metric schema for every experiment dimension and makes the debug/benchmark surfaces immediately useful for attribution.

### Show per-experiment labels in the debug tab
The debug tab should render each enabled experiment as a separate label instead of collapsing them into a single summary string. This keeps the developer-facing visibility aligned with the runtime state and makes it easier to verify combinations at a glance.

### Add label-based filtering to the debug tab
The debug tab should support filtering by experiment label so a developer can narrow the view to one active slice when several are enabled. A simple label filter keeps the control lightweight and avoids coupling the debug panel to any particular experiment implementation detail.

### Keep the debug tab results-first
The debug tab should default to metric summaries, not experiment configuration. Experiment state should appear as a compact status row with active labels and a configuration affordance, while the full switch panel opens in a separate sheet. This keeps latency readings visible on launch, avoids pushing results below the fold, and still gives developers fast access to every flag. The label filter belongs with the metric summaries because filtering is a result-reading task, not a configuration task.

### Roll out the experiments in a staged order
The initial slice should be the flag plumbing and measurement wiring. After that, the most likely Flash latency reducers should be tried first: model selection, schema strictness, prompt/context reduction, output token budget, confidence threshold, and disabling escalation. Streaming, speculative parallelization, and caching should remain available as separate future changes because they change either the user experience, cost profile, or request lifecycle more materially.

## Risks / Trade-offs

- [Flag explosion] More toggles can make the system hard to reason about. → Keep the flag set small, name each lever explicitly, and remove flags once an experiment is accepted or rejected.
- [Combination ambiguity] Multiple flags enabled together can blur causality. → Ship and benchmark one slice at a time by default; only combine slices deliberately.
- [Hidden regressions] A flag applied deep in the pipeline could change behavior outside the intended slice. → Pass a single snapshot through the request path and cover each branch with tests.
- [Debug surface clutter] Too many experiment labels can make the metrics UI noisy. → Show compact per-experiment labels and keep the control UI in debug-only surfaces.
- [Filter complexity] Adding filtering can make the debug tab feel busy if it grows into a general query system. → Keep filtering label-based and narrow in scope to experiment visibility.
- [Control panel dominance] Experiment controls can crowd out the metrics they are meant to explain. → Keep the default debug screen results-first and put full controls behind a sheet.
- [Stale experiment state] Old toggles can linger after a decision is made. → Add follow-up cleanup tasks to retire obsolete flags once a slice is merged or discarded.
- [Premature placeholders] Adding flags for future work can make the debug panel imply behavior that does not exist yet. → Exclude streaming, caching, and speculative parallel flags until their implementations are in scope.

## Migration Plan

1. Add the flag store and default-off snapshot plumbing.
2. Wire metrics and debug surfaces to report the active flag set.
3. Move full experiment controls into a separate debug configuration panel while keeping metric summaries visible by default.
4. Enable and test one optimization slice at a time.
5. Keep a rollback path for each slice by disabling the corresponding flag.
6. Remove or collapse flags after each slice is either accepted or abandoned.

## Open Questions

- Should the flag store persist in `UserDefaults`, SwiftData, or an existing debug-only configuration file?
- Should streaming become a later UX-focused OpenSpec change?
- Should context caching and speculative parallelization each get their own cost-aware OpenSpec changes?
