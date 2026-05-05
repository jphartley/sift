## MODIFIED Requirements

### Requirement: User can start a voice check-in

The system SHALL allow the user to initiate a voice recording to describe how they are feeling or what is on their mind. The system SHALL request microphone permission on first launch and display the recording state (idle, loading model, ready, recording) to the user. The WhisperKit speech model SHALL preload at app launch via `siftApp.task`.

#### Scenario: First launch loads WhisperKit model
- **WHEN** the app launches for the first time
- **THEN** the system SHALL begin loading the WhisperKit model immediately (in `siftApp.task`), concurrent with UI rendering
- **THEN** the system SHALL display a progress bar with download percentage during the download phase
- **THEN** the system SHALL display a loading indicator during the compilation phase
- **THEN** the system SHALL transition to the ready state once the model is loaded

#### Scenario: Microphone permission denied
- **WHEN** the user has denied microphone permission
- **THEN** the system SHALL display an error message explaining that microphone access is required

#### Scenario: Model fails to load
- **WHEN** the WhisperKit model fails to load
- **THEN** the system SHALL display an error message with a retry option
