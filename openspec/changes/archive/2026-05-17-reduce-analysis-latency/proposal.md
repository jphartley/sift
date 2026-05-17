## Why

The new benchmark results show that the analysis phase is not just “a bit slow” but consistently expensive even on Flash-only runs: 7.6s min, 8.5s median, and 10.2s max across 20 samples, with confidence staying high enough to avoid Pro escalation entirely. That shifts the problem from “maybe escalation is hurting us” to “Flash itself is too slow,” so we need a controlled way to test latency-reduction ideas one by one without mixing their effects.

## What Changes

- Add a feature-flagged experiment layer for analysis-phase behavior so individual latency levers can be enabled, disabled, and measured independently.
- Keep current behavior as the default when all flags are off.
- Introduce a staged set of experiments that can be shipped one at a time:
  - Flash model selection between the Gemini 3 preview path and a stable Flash model.
  - Response schema strictness.
  - Prompt/context reduction.
  - Output token budget.
  - Escalation threshold and escalation disabling.
- Add explicit test coverage for each flaggable branch so each experiment can be verified without live Gemini calls.
- Make the debug/benchmark surface able to distinguish which experiment set produced a timing sample.
- Rework the debug metrics screen so metric results remain visible by default while experiment controls open in a separate configuration panel.

## Capabilities

### New Capabilities
- `analysis-latency-experiments`: runtime-controlled experiment flags and rollout plumbing for analysis-phase optimization work.

### Modified Capabilities
- None. This proposal keeps the existing recommendation behavior as the baseline and layers experiments on top without changing the default contract.

## Impact

- `GeminiRecommendationRouter`, `GeminiService`, and `GeminiPromptBuilder` will need flag-aware branches for model choice, schema handling, prompt shape, and token limits.
- `MetricRecorder` and the debug metrics surface will need to record which experiment combination was active for each measurement.
- `DebugMetricsScreen` will need a results-first layout, label filtering, active experiment labels, and a separate experiment configuration panel.
- New and updated tests will be required for each flag branch and for the default-off behavior.
