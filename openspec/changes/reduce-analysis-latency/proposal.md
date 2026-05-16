## Why

The new benchmark results show that the analysis phase is not just “a bit slow” but consistently expensive even on Flash-only runs: 7.6s min, 8.5s median, and 10.2s max across 20 samples, with confidence staying high enough to avoid Pro escalation entirely. That shifts the problem from “maybe escalation is hurting us” to “Flash itself is too slow,” so we need a controlled way to test latency-reduction ideas one by one without mixing their effects.

## What Changes

- Add a feature-flagged experiment layer for analysis-phase behavior so individual latency levers can be enabled, disabled, and measured independently.
- Keep current behavior as the default when all flags are off.
- Introduce a staged set of experiments that can be shipped one at a time:
  - Flash model selection changes.
  - Response schema strictness changes.
  - Prompt/context reduction changes.
  - Output token budget changes.
  - Escalation threshold changes.
  - Streaming / perceived-latency changes.
  - Context caching and speculative parallelization experiments.
- Add explicit test coverage for each flaggable branch so each experiment can be verified without live Gemini calls.
- Make the debug/benchmark surface able to distinguish which experiment set produced a timing sample.

## Capabilities

### New Capabilities
- `analysis-latency-experiments`: runtime-controlled experiment flags and rollout plumbing for analysis-phase optimization work.

### Modified Capabilities
- None. This proposal keeps the existing recommendation behavior as the baseline and layers experiments on top without changing the default contract.

## Impact

- `GeminiRecommendationRouter`, `GeminiService`, and `GeminiPromptBuilder` will need flag-aware branches for model choice, schema handling, prompt shape, and token limits.
- `RecordingViewModel` and the analysis/suggestion flow may need small orchestration updates for streaming or speculative execution experiments.
- `MetricRecorder` and the debug metrics surface will need to record which experiment combination was active for each measurement.
- New and updated tests will be required for each flag branch and for the default-off behavior.
