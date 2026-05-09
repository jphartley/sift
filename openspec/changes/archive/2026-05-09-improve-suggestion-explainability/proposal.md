## Why

The suggestion screen is the moment where Sift earns trust after a vulnerable check-in. For beta users, the current "Analysis" framing and model-escalation toast can make the experience feel like debug output instead of a practical, relational coaching handoff.

## What Changes

- Reframe the suggestion rationale as human-facing coaching context rather than "analysis" or model output.
- Keep per-practice relevance visible, but present it as plain-language support for why that practice might fit.
- Hide model-routing details such as Pro escalation, model names, provider names, and confidence data from the main suggestion UI.
- Preserve internal recommendation metadata for routing, persistence, debugging, and history where already supported.
- Add regression coverage so the beta-facing suggestion flow continues to show rationale/relevance while avoiding implementation-language leaks.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `suggestion-interaction`: Defines human-facing explainability behavior for the suggestion screen and expanded practice cards.
- `gemini-practice-recommendation`: Updates recommendation display requirements so rationale/relevance are shown without exposing Gemini/model implementation details in the main suggestion UI.
- `voice-check-in`: Clarifies that confidence and escalation metadata remain internal to the check-in flow rather than user-facing in the main suggestion UI.
- `automated-tests`: Adds coverage expectations for suggestion explainability copy and hidden model-routing details.

## Impact

- `sift/Views/SuggestionView.swift`
- Potential view-adjacent presentation constants or helpers for testable suggestion copy.
- `siftTests/` coverage for suggestion copy, rationale/relevance visibility, and absence of model/provider/debug terminology.
- No changes to Gemini routing, persistence schema, model names, API keys, or external dependencies.
