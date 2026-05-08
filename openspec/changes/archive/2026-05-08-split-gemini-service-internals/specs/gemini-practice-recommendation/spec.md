## ADDED Requirements

### Requirement: Gemini recommendation behavior remains compatible after internal split
The system SHALL preserve the existing Gemini practice recommendation behavior when `GeminiService` is refactored into focused internal collaborators.

#### Scenario: Gemini returns recommendations successfully
- **WHEN** Gemini responds with valid structured JSON after the internal split
- **THEN** the system SHALL extract 2-3 practice IDs, an overarching rationale, per-practice relevance text, and a confidence score
- **THEN** the system SHALL return recommendation result data compatible with the suggestion view and session persistence

#### Scenario: Flash routes to Pro after low confidence
- **WHEN** the Flash response returns confidence below 0.7 after the internal split
- **THEN** the system SHALL retry the request with `gemini-3.1-pro-preview`
- **THEN** the system SHALL use the Pro response regardless of its confidence

#### Scenario: Gemini returns invalid JSON after internal split
- **WHEN** Gemini returns a response that cannot be parsed into the expected structured output schema after the internal split
- **THEN** the system SHALL treat this as a failure compatible with the existing Gemini error flow

#### Scenario: API key is missing after internal split
- **WHEN** `Secrets.geminiApiKey` is empty
- **THEN** the first Gemini recommendation request SHALL fail with the existing missing API key error
