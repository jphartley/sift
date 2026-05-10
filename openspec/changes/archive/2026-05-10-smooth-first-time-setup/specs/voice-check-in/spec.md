## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: First-time setup preserves trust during speech preparation

The system SHALL present first-time setup copy in calm, plain language so users understand why they cannot record yet.

#### Scenario: Downloading model shows progress and context
- **WHEN** the speech model is downloading
- **THEN** the setup presentation SHALL show determinate progress
- **THEN** the setup presentation SHALL explain that Sift is getting on-device speech recognition ready
- **THEN** the setup presentation SHALL avoid prototype terms such as "speech model"

#### Scenario: Preparing model shows active state and context
- **WHEN** the speech model has downloaded and is being prepared locally
- **THEN** the setup presentation SHALL show an active indeterminate loading state
- **THEN** the setup presentation SHALL explain that Sift is preparing on-device speech recognition
- **THEN** the setup presentation SHALL state that this may take a little while the first time

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
