## MODIFIED Requirements

### Requirement: System routes between Flash and Pro models based on confidence and server health

The system SHALL use `gemini-3-flash-preview` for every initial recommendation request. The system SHALL escalate to `gemini-3.1-pro-preview` when the Flash response returns a confidence score below 0.7. The system SHALL also silently fall back to Pro when Flash fails with a transient server error (HTTP 429, 500, 502, 503, 504, or "unavailable" status). Model-routing details SHALL remain internal and SHALL NOT be shown in the main suggestion UI.

#### Scenario: Flash returns high confidence

- **WHEN** `gemini-3-flash-preview` returns recommendations with confidence >= 0.7
- **THEN** the system SHALL use that response and SHALL NOT escalate to Pro

#### Scenario: Flash returns low confidence

- **WHEN** `gemini-3-flash-preview` returns recommendations with confidence < 0.7
- **THEN** the system SHALL retry the request with `gemini-3.1-pro-preview`
- **THEN** the system SHALL use the Pro response regardless of its confidence
- **THEN** the system SHALL preserve metadata that Pro escalation occurred for internal routing, persistence, debugging, or developer diagnostics
- **THEN** the system SHALL NOT show Pro escalation in the main suggestion UI

#### Scenario: Flash fails with transient server error

- **WHEN** `gemini-3-flash-preview` fails with an HTTP 429, 500, 502, 503, 504, or "unavailable" status
- **THEN** the system SHALL automatically retry the request with `gemini-3.1-pro-preview` without showing an error to the user
- **THEN** the system SHALL log the fallback to the console
- **THEN** the system SHALL preserve metadata that Pro escalation occurred for internal routing, persistence, debugging, or developer diagnostics
- **THEN** the system SHALL NOT show Pro escalation in the main suggestion UI

#### Scenario: Both Flash and Pro fail

- **WHEN** both `gemini-3-flash-preview` and `gemini-3.1-pro-preview` fail
- **THEN** the system SHALL display an error message with a retry button

### Requirement: System displays Gemini rationale and relevance

The system SHALL display the recommendation rationale and per-practice relevance text in human-facing coaching language. The main suggestion UI SHALL NOT label these explanations as Gemini output, model output, confidence data, routing data, or debug information.

#### Scenario: Gemini recommendations include rationale

- **WHEN** Gemini returns an overarching rationale string
- **THEN** the system SHALL display the rationale prominently in the suggestion view before the practice cards
- **THEN** the rationale SHALL be presented with a coaching-flavored label such as "Why these might fit"
- **THEN** the rationale presentation SHALL avoid provider names, model names, confidence scores, routing terms, and debug language

#### Scenario: Gemini recommendations include per-practice relevance

- **WHEN** Gemini returns a relevance string for a given practice
- **THEN** the system SHALL display that relevance text on or below the corresponding practice card when the card is expanded
- **THEN** the relevance presentation SHALL avoid provider names, model names, confidence scores, routing terms, and debug language
