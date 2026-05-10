## ADDED Requirements

### Requirement: Tests cover first-time setup presentation

The system SHALL have automated tests verifying that the model-loading setup experience is clear, reassuring, and phase-specific.

#### Scenario: Setup copy is covered
- **WHEN** automated tests exercise first-time setup presentation data
- **THEN** the tests SHALL verify that setup copy explains Sift is preparing on-device speech recognition
- **THEN** the tests SHALL verify that setup copy says first setup can take a little while
- **THEN** the tests SHALL verify that setup copy avoids prototype terms such as "speech model"

#### Scenario: Download phase presentation is covered
- **WHEN** automated tests exercise setup presentation for model downloading
- **THEN** the tests SHALL verify that determinate progress is represented
- **THEN** the tests SHALL verify that the status copy describes getting speech recognition ready

#### Scenario: Local preparation phase presentation is covered
- **WHEN** automated tests exercise setup presentation for local model preparation
- **THEN** the tests SHALL verify that an active loading state is represented
- **THEN** the tests SHALL verify that the status copy describes preparing speech recognition on device

#### Scenario: Existing ready orientation remains covered
- **WHEN** automated tests run after setup presentation changes
- **THEN** existing ready-screen orientation tests SHALL continue to verify the ready check-in screen copy

### Requirement: Tests cover responsive microphone startup

The system SHALL have automated tests verifying that the first microphone tap is acknowledged immediately and cannot trigger overlapping startup work.

#### Scenario: Preparing-to-record state is covered
- **WHEN** automated tests call recording start from the ready state with permission still pending
- **THEN** the tests SHALL verify that the view model enters a preparing-to-record state before recording begins
- **THEN** the tests SHALL verify that the UI copy for this state includes "Getting microphone ready"

#### Scenario: Duplicate start taps are ignored
- **WHEN** automated tests call recording start more than once while startup is pending
- **THEN** the tests SHALL verify that only one recorder startup request is made
- **THEN** the tests SHALL verify that recording still starts once permission and recorder setup succeed

#### Scenario: Permission denial recovery remains covered
- **WHEN** automated tests exercise microphone permission denial during startup
- **THEN** the tests SHALL verify that the preparing-to-record state exits
- **THEN** the tests SHALL verify that the microphone recovery state remains available

### Requirement: Tests cover startup storage preparation

The system SHALL have automated tests or static checks verifying that startup prepares the local storage parent directory before SwiftData initialization.

#### Scenario: Application Support directory preparation is covered
- **WHEN** automated tests or static checks inspect app startup behavior
- **THEN** they SHALL verify that the Application Support directory is created before `ModelContainer` initialization
- **THEN** they SHALL verify that the default SwiftData store location and schema are not changed
