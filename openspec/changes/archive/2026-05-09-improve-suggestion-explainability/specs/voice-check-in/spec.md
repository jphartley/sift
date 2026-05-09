## MODIFIED Requirements

### Requirement: System suggests practices after transcription

After a successful transcription, the system SHALL submit the transcript plus user history to Gemini for analysis. The system SHALL display 2-3 practice suggestions based on Gemini's structured response, which includes an overarching rationale and per-practice relevance text. The system SHALL use `gemini-3-flash-preview` by default and escalate to `gemini-3.1-pro-preview` when confidence is below 0.7. Confidence and escalation metadata SHALL remain internal to routing, persistence, debugging, or developer diagnostics and SHALL NOT be shown in the main suggestion UI.

#### Scenario: Gemini returns practice recommendations

- **WHEN** Gemini returns valid practice recommendations
- **THEN** the system SHALL display up to 3 practices with human-facing rationale and relevance text
- **THEN** the system SHALL NOT display confidence data, model names, provider names, or escalation details in the main suggestion UI

#### Scenario: Gemini returns no matching practices

- **WHEN** Gemini returns an empty practices array
- **THEN** the system SHALL display the empty state with an appropriate message

#### Scenario: User has prior helpful practices

- **WHEN** the user has marked practices as helpful in prior sessions
- **THEN** the system SHALL include that history in the Gemini prompt for context-aware recommendations

### Requirement: Check-in flow preserves behavior while using injectable services

The system SHALL preserve the existing voice check-in user flow while `RecordingViewModel` depends on service protocols and a session store rather than concrete service implementations.

#### Scenario: Successful check-in still reaches suggestions
- **WHEN** recording stops, transcription succeeds, and recommendations are returned
- **THEN** the system SHALL create a pending session with transcript and transcription duration
- **THEN** the system SHALL transition through analyzing to suggesting with recommended practices, rationale, escalation state, and relevance text
- **THEN** escalation state SHALL remain available to internal flow state without being displayed as model-routing copy in the main suggestion UI

#### Scenario: User completes reflection
- **WHEN** the user selects a practice and saves reflection
- **THEN** the system SHALL persist the session and attempt through the session store
- **THEN** the system SHALL reset the check-in flow to the ready state after a successful save

#### Scenario: User skips suggestions
- **WHEN** the user skips suggestions after recommendations are shown
- **THEN** the system SHALL persist the session without attempts through the session store
- **THEN** the system SHALL reset the check-in flow to the ready state after a successful save
