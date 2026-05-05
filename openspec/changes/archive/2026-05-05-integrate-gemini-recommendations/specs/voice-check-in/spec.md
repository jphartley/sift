## MODIFIED Requirements

### Requirement: System transcribes audio on-device

The system SHALL transcribe recorded audio using WhisperKit on-device. The system SHALL display a transcribing indicator while processing. Upon successful transcription, the system SHALL transition to the analyzing state for Gemini-based practice recommendation.

#### Scenario: Successful transcription

- **WHEN** transcription completes successfully
- **THEN** the system SHALL display the transcribed text and transition to the analyzing state

#### Scenario: Transcription fails

- **WHEN** transcription fails (e.g., model not loaded, file not found)
- **THEN** the system SHALL display an error message and allow the user to return to the ready state

### Requirement: System suggests practices after transcription

After a successful transcription, the system SHALL submit the transcript plus user history to Gemini for analysis. The system SHALL display 2–3 practice suggestions based on Gemini's structured response, which includes an overarching rationale and per-practice relevance text. The system SHALL use `gemini-3-flash-preview` by default and escalate to `gemini-3.1-pro-preview` when confidence is below 0.7.

#### Scenario: Gemini returns practice recommendations

- **WHEN** Gemini returns valid practice recommendations
- **THEN** the system SHALL display up to 3 practices with rationale, relevance text, and confidence data

#### Scenario: Gemini returns no matching practices

- **WHEN** Gemini returns an empty practices array
- **THEN** the system SHALL display the empty state with an appropriate message

#### Scenario: User has prior helpful practices

- **WHEN** the user has marked practices as helpful in prior sessions
- **THEN** the system SHALL include that history in the Gemini prompt for context-aware recommendations

### Requirement: System displays analyzing state between transcription and suggestions

The system SHALL display an analyzing state with a loading indicator after transcription completes and while Gemini is processing the recommendation request.

#### Scenario: Gemini analysis in progress

- **WHEN** the system is waiting for a Gemini recommendation response
- **THEN** the system SHALL display a loading indicator with "Analyzing..." text

#### Scenario: Gemini analysis completes

- **WHEN** Gemini returns a successful response
- **THEN** the system SHALL transition from the analyzing state to the suggesting state
