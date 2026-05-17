## Why

Sift needs a short first-time intake so practice recommendations can respect a user's boundaries, prior experience, and preferred coaching language before the first voice check-in. This should improve recommendation quality while helping the user feel understood from the start.

## What Changes

- Add a first-time intake flow before the user's first check-in, with a brief product introduction, three high-signal intake prompts, and an optional deeper tuning step.
- Make intake voice-first, supported by tap-based chips where structure helps, so users can share richer context without filling out a long questionnaire.
- Analyze intake answers into a persisted user practice profile that can be used as context for future Gemini recommendation prompts.
- Treat some profile preferences as hard constraints, such as secular-only language or explicitly avoided practice types, while treating softer experience signals as ranking priors.
- Add evidence-grounding metadata to the practice library so research-backed-only users can receive only practices with explicit research grounding.
- Add backlog notes for later profile review/editing and resurfacing optional intake questions after the user has built trust through the core loop.

## Capabilities

### New Capabilities
- `first-time-intake`: Introduces the skippable first-time intake flow, intake profile persistence, voice-plus-chip response capture, and optional deeper tuning before the first check-in.

### Modified Capabilities
- `gemini-practice-recommendation`: Recommendation prompts and validation must include intake profile constraints, ranking priors, and explicit override rules.
- `yaml-practice-library`: Practice metadata must support explicit evidence grounding and preference/constraint matching.

## Impact

- Affected models: new persisted user practice profile model or equivalent profile storage.
- Affected views/view models: app launch or recording entry flow, intake screens, recording flow gating, and test fakes.
- Affected services: intake transcription/analysis, Gemini prompt construction, recommendation validation, and session context assembly.
- Affected data: bundled practice YAML schema and validation tests for evidence grounding metadata.
- Affected tests: first-time intake state, profile analysis and persistence, prompt construction, recommendation filtering/validation, practice library decoding, and user-facing intake copy.
