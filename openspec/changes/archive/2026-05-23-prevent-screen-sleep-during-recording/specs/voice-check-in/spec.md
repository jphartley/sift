## ADDED Requirements

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
