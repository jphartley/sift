## ADDED Requirements

### Requirement: User can start a voice check-in

The system SHALL allow the user to initiate a voice recording to describe how they are feeling or what is on their mind. The system SHALL request microphone permission on first launch and display the recording state (idle, loading model, ready, recording) to the user.

#### Scenario: First launch loads WhisperKit model
- **WHEN** the app launches for the first time
- **THEN** the system SHALL display a loading indicator while the WhisperKit model downloads and loads
- **THEN** the system SHALL transition to the ready state once the model is loaded

#### Scenario: Microphone permission denied
- **WHEN** the user has denied microphone permission
- **THEN** the system SHALL display an error message explaining that microphone access is required

#### Scenario: Model fails to load
- **WHEN** the WhisperKit model fails to load
- **THEN** the system SHALL display an error message with a retry option

### Requirement: User can record and view their spoken input

The system SHALL record audio in PCM 16kHz mono WAV format and display a live audio level meter during recording. The system SHALL display the current recording duration in seconds.

#### Scenario: Recording in progress
- **WHEN** the user taps the record button
- **THEN** the system SHALL begin recording audio and display a live audio level visualization that updates at least every 100ms

#### Scenario: User stops recording
- **WHEN** the user taps the stop button
- **THEN** the system SHALL stop recording and begin transcription

### Requirement: System transcribes audio on-device

The system SHALL transcribe recorded audio using WhisperKit on-device. The system SHALL display a transcribing indicator while processing.

#### Scenario: Successful transcription
- **WHEN** transcription completes successfully
- **THEN** the system SHALL display the transcribed text and transition to the practice suggestion view

#### Scenario: Transcription fails
- **WHEN** transcription fails (e.g., model not loaded, file not found)
- **THEN** the system SHALL display an error message and allow the user to return to the ready state

### Requirement: System suggests practices after transcription

After a successful transcription, the system SHALL display 2–3 practice suggestions based on the content of the user's spoken input. The system SHALL match keywords in the transcript against each practice's keyword set and surface the most relevant practices.

#### Scenario: Keywords match practices
- **WHEN** the transcript contains keywords matching one or more practices
- **THEN** the system SHALL display up to 3 matching practices, ordered by relevance score

#### Scenario: No keywords match
- **WHEN** the transcript contains no matching keywords for any practice
- **THEN** the system SHALL display up to 3 fallback practices (the most commonly helpful practices from prior sessions)

#### Scenario: User has prior helpful practices
- **WHEN** the user has marked practices as helpful in prior sessions
- **THEN** the system SHALL boost those practices in the suggestion ordering
