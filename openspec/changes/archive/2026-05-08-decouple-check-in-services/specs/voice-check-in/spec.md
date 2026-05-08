## ADDED Requirements

### Requirement: Check-in flow preserves behavior while using injectable services
The system SHALL preserve the existing voice check-in user flow while `RecordingViewModel` depends on service protocols and a session store rather than concrete service implementations.

#### Scenario: Successful check-in still reaches suggestions
- **WHEN** recording stops, transcription succeeds, and recommendations are returned
- **THEN** the system SHALL create a pending session with transcript and transcription duration
- **THEN** the system SHALL transition through analyzing to suggesting with recommended practices, rationale, escalation state, and relevance text

#### Scenario: User completes reflection
- **WHEN** the user selects a practice and saves reflection
- **THEN** the system SHALL persist the session and attempt through the session store
- **THEN** the system SHALL reset the check-in flow to the ready state after a successful save

#### Scenario: User skips suggestions
- **WHEN** the user skips suggestions after recommendations are shown
- **THEN** the system SHALL persist the session without attempts through the session store
- **THEN** the system SHALL reset the check-in flow to the ready state after a successful save

### Requirement: Check-in flow surfaces dependency failures
The system SHALL surface failures from injected transcription, recommendation, and session storage dependencies through a user-visible error state.

#### Scenario: Transcription dependency fails
- **WHEN** the transcription client throws while transcribing recorded audio
- **THEN** the system SHALL display an error message
- **THEN** the pending session SHALL NOT be persisted

#### Scenario: Recommendation dependency fails
- **WHEN** the recommendation client throws while analyzing a transcript
- **THEN** the system SHALL display an error message with retry behavior for recommendation analysis
- **THEN** the pending transcript SHALL remain available for retry

#### Scenario: Session store save fails
- **WHEN** the session store fails to save a completed or skipped session
- **THEN** the system SHALL display an error message
- **THEN** the system SHALL NOT silently reset as though persistence succeeded
