## ADDED Requirements

### Requirement: Check-in flow dependencies are injectable
The system SHALL define narrow service protocols for the voice check-in flow so the recorder, transcription client, recommendation client, and session persistence/history store can be replaced in tests without changing user-facing behavior.

#### Scenario: Production services satisfy check-in protocols
- **WHEN** the app configures the recording screen for normal use
- **THEN** the production audio recorder, transcription service, recommendation service, and session store SHALL satisfy the protocols required by the check-in flow

#### Scenario: Tests use deterministic fakes
- **WHEN** automated tests instantiate the check-in flow
- **THEN** tests SHALL be able to provide fake implementations for audio recording, transcription, recommendation, and session storage

### Requirement: Session persistence is abstracted behind a store
The system SHALL route session saving and recommendation history retrieval through a session store boundary instead of direct SwiftData calls in the check-in view model.

#### Scenario: View model requests recommendation history
- **WHEN** the check-in flow needs prior sessions for recommendation context
- **THEN** the view model SHALL request history from the session store
- **THEN** the view model SHALL NOT construct SwiftData fetch descriptors directly

#### Scenario: View model persists completed session
- **WHEN** the user completes reflection or skips suggestions
- **THEN** the view model SHALL ask the session store to save the pending session
- **THEN** save failures SHALL be observable by the view model

### Requirement: Protocols remain scoped to current flow behavior
The system SHALL keep check-in service protocols limited to operations currently needed by the voice check-in flow.

#### Scenario: Protocol is defined for transcription
- **WHEN** the transcription dependency is abstracted
- **THEN** the protocol SHALL expose model state and audio transcription behavior only
- **THEN** it SHALL NOT expose unrelated WhisperKit implementation details

#### Scenario: Protocol is defined for recommendations
- **WHEN** the recommendation dependency is abstracted
- **THEN** the protocol SHALL expose transcript-plus-history recommendation behavior only
- **THEN** it SHALL NOT expose Gemini-specific implementation details to the view model
