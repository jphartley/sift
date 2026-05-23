## Purpose
Define the end-to-end voice check-in flow from model loading and recording through transcription, analysis, suggestions, persistence, and task cancellation.
## Requirements
### Requirement: User can start a voice check-in

The system SHALL allow the user to initiate a voice recording to describe how they are feeling or what is on their mind. The system SHALL request microphone permission on first launch and display the recording state (idle, loading model, ready, preparing to record, recording) to the user. The WhisperKit speech model SHALL preload at app launch via `siftApp.task`. While the speech model is downloading or preparing, the system SHALL show a first-time setup presentation that explains Sift is preparing on-device speech recognition and that first setup can take a little while. When the user taps the microphone, the system SHALL immediately acknowledge that recording setup has started while microphone permission and recorder startup complete.

#### Scenario: First launch loads WhisperKit model
- **WHEN** the app launches for the first time
- **THEN** the system SHALL begin loading the WhisperKit model immediately (in `siftApp.task`), concurrent with UI rendering
- **THEN** the system SHALL display a first-time setup title and explanation while the model is not ready
- **THEN** the system SHALL display a progress bar with download percentage during the download phase
- **THEN** the system SHALL display an active loading indicator during the local preparation phase
- **THEN** the setup copy SHALL state that Sift is preparing on-device speech recognition
- **THEN** the setup copy SHALL state that first setup can take a little while
- **THEN** the system SHALL transition to the ready state once the model is loaded

#### Scenario: Microphone permission denied
- **WHEN** the user has denied microphone permission
- **THEN** the system SHALL display an error message explaining that microphone access is required

#### Scenario: First microphone tap is acknowledged immediately
- **WHEN** the user taps the recording action from the ready state
- **THEN** the system SHALL immediately transition to a preparing-to-record state
- **THEN** the system SHALL display copy indicating that Sift is getting the microphone ready
- **THEN** repeated taps while preparing SHALL NOT start overlapping recording setup work

#### Scenario: Microphone setup succeeds
- **WHEN** microphone permission is granted and recorder startup succeeds
- **THEN** the system SHALL transition from preparing-to-record to recording

#### Scenario: Model fails to load
- **WHEN** the WhisperKit model fails to load
- **THEN** the system SHALL display an error message with a retry option

### Requirement: First-time setup preserves trust during speech preparation

The system SHALL present first-time setup copy in calm, plain language so users understand why they cannot record yet. The loading screen SHALL display the title and footer note only — the inline subtitle explaining on-device speech recognition SHALL NOT be shown.

#### Scenario: Downloading model shows progress and context
- **WHEN** the speech model is downloading
- **THEN** the setup presentation SHALL show determinate progress
- **THEN** the setup presentation SHALL show the title "Getting Sift ready"
- **THEN** the setup presentation SHALL show the footer note that first setup can take a little while
- **THEN** the setup presentation SHALL NOT display an inline subtitle beneath the title
- **THEN** the setup presentation SHALL avoid prototype terms such as "speech model"

#### Scenario: Preparing model shows active state and context
- **WHEN** the speech model has downloaded and is being prepared locally
- **THEN** the setup presentation SHALL show an active indeterminate loading state
- **THEN** the setup presentation SHALL show the title "Getting Sift ready"
- **THEN** the setup presentation SHALL show the footer note that first setup can take a little while
- **THEN** the setup presentation SHALL NOT display an inline subtitle beneath the title

#### Scenario: Ready state replaces setup
- **WHEN** speech recognition is ready
- **THEN** the setup presentation SHALL no longer be visible
- **THEN** the regular ready check-in orientation SHALL be visible

### Requirement: First microphone tap feels responsive

The system SHALL visibly acknowledge the user's first attempt to record while microphone permission and recorder startup complete.

#### Scenario: Preparing to record shows responsive feedback
- **WHEN** recording startup is in progress
- **THEN** the UI SHALL show "Getting microphone ready..."
- **THEN** the primary record button SHALL NOT remain in its normal idle appearance
- **THEN** the UI SHALL prevent duplicate recording-start requests until startup completes

#### Scenario: Permission denial exits preparing state
- **WHEN** microphone permission is denied during recording startup
- **THEN** the system SHALL leave the preparing-to-record state
- **THEN** the system SHALL show the existing microphone recovery state with an "Open Settings" action

#### Scenario: Recorder startup failure exits preparing state
- **WHEN** recorder startup fails after permission is granted
- **THEN** the system SHALL leave the preparing-to-record state
- **THEN** the system SHALL show an error or recovery state instead of staying stuck

### Requirement: First launch prepares local storage directory

The system SHALL ensure the app's Application Support directory exists before initializing the SwiftData model container.

#### Scenario: App starts on clean install
- **WHEN** the app launches after a clean install
- **THEN** the system SHALL create the Application Support directory before creating the SwiftData `ModelContainer`
- **THEN** the system SHALL keep the default SwiftData store location and schema unchanged

#### Scenario: Application Support already exists
- **WHEN** the app launches and the Application Support directory already exists
- **THEN** startup SHALL continue without deleting or replacing existing persisted data

### Requirement: User can record and view their spoken input

The system SHALL record audio in PCM 16kHz mono WAV format and display a live audio level meter during recording. The system SHALL display the current recording duration in seconds.

#### Scenario: Recording in progress
- **WHEN** the user taps the record button
- **THEN** the system SHALL begin recording audio and display a live audio level visualization that updates at least every 100ms

#### Scenario: User stops recording
- **WHEN** the user taps the stop button
- **THEN** the system SHALL stop recording and begin transcription

### Requirement: Recording keeps the screen awake while active
The system SHALL prevent the device screen from sleeping while an active voice recording is in progress. The system SHALL restore normal idle behavior once recording stops or the recording screen is torn down.

#### Scenario: Active recording keeps the device awake
- **WHEN** the user is actively recording a voice check-in
- **THEN** the system SHALL keep the screen awake for the duration of that recording

#### Scenario: Recording stop restores normal idle behavior
- **WHEN** the user stops recording
- **THEN** the system SHALL restore normal idle timer behavior

#### Scenario: Screen teardown restores normal idle behavior
- **WHEN** the recording screen disappears while recording is active
- **THEN** the system SHALL restore normal idle timer behavior

#### Scenario: Startup failure does not keep the screen awake
- **WHEN** microphone permission is denied or recorder startup fails before recording becomes active
- **THEN** the system SHALL keep normal idle timer behavior

### Requirement: System transcribes audio on-device

The system SHALL transcribe recorded audio using WhisperKit on-device. The system SHALL display a transcribing indicator while processing. Upon successful transcription, the system SHALL transition to the analyzing state for Gemini-based practice recommendation.

#### Scenario: Successful transcription

- **WHEN** transcription completes successfully
- **THEN** the system SHALL display the transcribed text and transition to the analyzing state

#### Scenario: Transcription fails

- **WHEN** transcription fails (e.g., model not loaded, file not found)
- **THEN** the system SHALL display an error message and allow the user to return to the ready state

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
- **THEN** escalation state SHALL remain available to internal flow state without being displayed as model-routing copy in the main suggestion UI

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

### Requirement: Ready check-in screen orients users

The system SHALL display first-screen orientation in the ready recording state so users understand how to begin a voice check-in without external explanation. The orientation SHALL be presented as a single concise paragraph and a "For example:" list of starter prompts.

#### Scenario: Ready state explains how to check in
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL display the heading "Take a moment to arrive"
- **THEN** the system SHALL NOT display a separate date or time label above the heading
- **THEN** the system SHALL display a single orientation paragraph inviting the user to speak for about a minute about what feels most alive right now
- **THEN** the orientation paragraph SHALL mention examples: what happened, how it feels, or what kind of support the user wants
- **THEN** the orientation paragraph SHALL explain that Sift will reflect back what it heard and suggest a few practices to choose from
- **THEN** the system SHALL NOT display a separate second paragraph for the "what happens next" explanation

#### Scenario: Ready state offers starter prompts as a plain list
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL display a "For example:" label followed by the starter prompts
- **THEN** the starter prompts SHALL be rendered as plain italic text with no border, background, or tappable styling
- **THEN** the starter prompts SHALL include "Right now I notice...", "What feels hard is...", and "What I need is..."

#### Scenario: Ready state preserves recording action
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL keep the microphone recording action available as the primary action
- **THEN** tapping the recording action SHALL continue to start recording

#### Scenario: Returning ready state uses simpler guidance
- **WHEN** the recording screen is in the ready state after a previous transcript is available
- **THEN** the system SHALL display the heading "Check in again"
- **THEN** the system SHALL display the guidance "Record another short voice note about what feels most alive right now. A minute is enough."
- **THEN** the system SHALL omit starter prompts from the returning ready state

#### Scenario: Check-in flow omits persistent navigation title
- **WHEN** the user is in the recording check-in flow
- **THEN** the system SHALL NOT display a persistent "Check In" navigation title above the flow content

### Requirement: Recording state presents minimal UI

The system SHALL display a minimal recording UI so the user can focus on speaking without distraction.

#### Scenario: Recording in progress shows minimal text
- **WHEN** the system is in the recording state
- **THEN** the system SHALL display "Take your time." as the only text above the waveform
- **THEN** the system SHALL NOT display a "LISTENING" status label
- **THEN** the system SHALL NOT display "I'm here." text
- **THEN** the system SHALL NOT display a privacy note below the stop button

#### Scenario: Recording in progress shows waveform and stop action
- **WHEN** the system is in the recording state
- **THEN** the system SHALL display a live audio waveform visualization
- **THEN** the system SHALL display a "Stop" button to end recording

### Requirement: Analyzing state presents minimal UI

The system SHALL display a minimal analyzing UI that focuses attention on the loading state without supplementary copy.

#### Scenario: Analyzing state shows title only
- **WHEN** the system is in the analyzing state
- **THEN** the system SHALL display "Reading what you shared"
- **THEN** the system SHALL NOT display a subtitle beneath the title
- **THEN** the system SHALL display the transcript text when available

### Requirement: Suggestion screen prioritises rationale over transcript

The suggestion screen SHALL visually prioritise the "Why these might fit" rationale over the "YOU SHARED" transcript so users encounter the most useful content first.

#### Scenario: Transcript is displayed as secondary content
- **WHEN** the suggestion screen is displayed
- **THEN** the transcript SHALL be rendered in a visually secondary style (muted/quiet color)
- **THEN** the rationale heading "Why these might fit" SHALL use a prominent heading font
- **THEN** the rationale text SHALL use the primary ink color

#### Scenario: Memory insert card is not shown
- **WHEN** the suggestion screen is displayed regardless of prior session history
- **THEN** the system SHALL NOT display a "WHAT I REMEMBER" memory insert card

#### Scenario: Skip button is clearly active
- **WHEN** the suggestion screen is displayed
- **THEN** the skip/done button SHALL display the label "I'm good for now"
- **THEN** the button SHALL be styled to appear clearly interactive and active

### Requirement: Reflection screen presents minimal header

The reflection screen SHALL display only the question heading without a preceding status label.

#### Scenario: Reflection screen shows question only
- **WHEN** the reflection screen is displayed
- **THEN** the system SHALL display "How did that land?" as the heading
- **THEN** the system SHALL NOT display an "AFTER" label above the heading

#### Scenario: Reflection notes placeholder is welcoming
- **WHEN** the reflection notes field is empty
- **THEN** the placeholder text SHALL read "(Optional) anything else you want to share..."

### Requirement: Check-in flow presents calm recovery states

The system SHALL present beta-ready recovery states for recoverable check-in failures using plain language, a specific next action, and calm visual treatment.

#### Scenario: Microphone permission recovery opens Settings
- **WHEN** the user has denied microphone permission
- **THEN** the system SHALL display a recovery state explaining that microphone access is needed to record a check-in
- **THEN** the recovery state SHALL provide an "Open Settings" action
- **THEN** activating "Open Settings" SHALL request opening the app's system Settings page
- **THEN** the recovery state SHALL provide a way to try microphone permission again after the user returns

#### Scenario: Model loading recovery
- **WHEN** the WhisperKit model fails to download or load
- **THEN** the system SHALL display a recovery state explaining that Sift could not prepare speech recognition
- **THEN** the recovery state SHALL reassure the user that nothing was lost
- **THEN** the recovery state SHALL provide a retry action for model loading

#### Scenario: Empty speech recovery
- **WHEN** transcription completes with empty or whitespace-only text
- **THEN** the system SHALL display a recovery state explaining that the check-in did not come through
- **THEN** the recovery state SHALL reassure the user that they did not do anything wrong
- **THEN** the recovery state SHALL provide a "Record again" action that returns the user to the ready recording state

#### Scenario: Analysis failure recovery preserves transcript
- **WHEN** recommendation analysis fails after a transcript has been created
- **THEN** the system SHALL display a recovery state explaining that suggestions did not load
- **THEN** the recovery state SHALL state that the check-in text is still available
- **THEN** the recovery state SHALL provide a retry action for suggestions
- **THEN** retrying suggestions SHALL reuse the existing transcript instead of asking the user to record again

#### Scenario: Empty suggestion recovery
- **WHEN** analysis completes but no usable practices can be shown
- **THEN** the system SHALL display a recovery state explaining that Sift could not find practices to show this time
- **THEN** the recovery state SHALL avoid implying that the user checked in incorrectly
- **THEN** the recovery state SHALL provide a retry action for suggestions

#### Scenario: Recovery states remain calm
- **WHEN** the system displays a recoverable check-in failure
- **THEN** the recovery state SHALL avoid raw technical error text as the primary user-facing message
- **THEN** the recovery state SHALL avoid visually alarming red treatment for non-emergency failures
