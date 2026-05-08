## ADDED Requirements

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
