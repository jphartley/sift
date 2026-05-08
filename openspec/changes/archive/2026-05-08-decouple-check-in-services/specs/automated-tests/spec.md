## ADDED Requirements

### Requirement: RecordingViewModel tests exercise real flow methods
The system SHALL have automated tests that call real `RecordingViewModel` methods with fake service implementations instead of manually reproducing persistence or state changes.

#### Scenario: completeReflection test calls completeReflection
- **WHEN** a test verifies reflection completion
- **THEN** the test SHALL call `completeReflection`
- **THEN** the test SHALL assert saved session data through the fake or in-memory session store

#### Scenario: skipSuggestions test calls skipSuggestions
- **WHEN** a test verifies skipped suggestions
- **THEN** the test SHALL call `skipSuggestions`
- **THEN** the test SHALL assert that a session without attempts was saved

#### Scenario: stopRecording test drives transcription and recommendation
- **WHEN** a test verifies the successful stop-recording flow
- **THEN** the test SHALL use fake transcription and recommendation clients
- **THEN** the test SHALL assert the resulting `.suggesting` state and pending session metadata

### Requirement: Tests cover dependency failure paths
The system SHALL have automated tests for service and persistence failures that are practical to trigger with protocol-backed fakes.

#### Scenario: Recommendation fake throws
- **WHEN** the recommendation fake throws during analysis
- **THEN** the test SHALL assert the view model enters an error state while retaining the pending transcript for retry

#### Scenario: Session store fake throws on save
- **WHEN** the session store fake throws while saving reflection or skipped suggestions
- **THEN** the test SHALL assert the view model enters an error state
- **THEN** the test SHALL assert the session was not reported as successfully saved

#### Scenario: History fake is passed to recommender
- **WHEN** the session store fake returns prior history
- **THEN** the test SHALL assert the recommendation fake receives that history
