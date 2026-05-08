## ADDED Requirements

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

### Requirement: User can record and view their spoken input

The system SHALL record audio in PCM 16kHz mono WAV format and display a live audio level meter during recording. The system SHALL display the current recording duration in seconds.

#### Scenario: Recording in progress
- **WHEN** the user taps the record button
- **THEN** the system SHALL begin recording audio and display a live audio level visualization that updates at least every 100ms

#### Scenario: User stops recording
- **WHEN** the user taps the stop button
- **THEN** the system SHALL stop recording and begin transcription

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

### Requirement: Check-in async work is owned and cancelable
The system SHALL keep task handles for recording meter polling and check-in analysis work started by the voice check-in flow so stale work can be canceled when it is no longer relevant.

#### Scenario: New recording replaces existing meter polling
- **WHEN** recording meter polling is started while a previous meter polling task exists
- **THEN** the system SHALL cancel the previous meter polling task before storing the replacement task

#### Scenario: Recording stop ends meter polling
- **WHEN** the user stops an active recording
- **THEN** the system SHALL cancel recording meter polling before or while transcription begins

#### Scenario: New analysis replaces existing analysis
- **WHEN** transcription/recommendation analysis starts while a previous analysis task exists
- **THEN** the system SHALL cancel the previous analysis task before storing the replacement task

### Requirement: Check-in teardown cancels in-flight work
The system SHALL provide a teardown path for the recording UI to cancel in-flight check-in work when the view disappears.

#### Scenario: Recording screen disappears during recording
- **WHEN** the recording screen disappears while recording is active
- **THEN** the system SHALL stop the active recording
- **THEN** the system SHALL cancel recording meter polling

#### Scenario: Recording screen disappears during analysis
- **WHEN** the recording screen disappears while transcription or recommendation analysis is in progress
- **THEN** the system SHALL cancel the in-flight analysis task
- **THEN** canceled analysis SHALL NOT publish suggestions, persistence changes, or a user-visible error caused only by cancellation

### Requirement: Canceled analysis does not publish stale state
The system SHALL prevent canceled transcription or recommendation work from updating the active check-in state after a newer flow has started or teardown has occurred.

#### Scenario: Canceled recommendation completes later
- **WHEN** a canceled recommendation request completes after cancellation
- **THEN** the system SHALL ignore its result
- **THEN** the system SHALL NOT replace the current state with stale suggestions

#### Scenario: Canceled transcription completes later
- **WHEN** a canceled transcription request completes after cancellation
- **THEN** the system SHALL ignore its result
- **THEN** the system SHALL NOT create or overwrite the pending session from canceled work
