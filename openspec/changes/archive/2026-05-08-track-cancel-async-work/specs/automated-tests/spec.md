## ADDED Requirements

### Requirement: Tests cover check-in async task lifecycle
The system SHALL have automated tests verifying that the voice check-in flow cancels and replaces owned async tasks.

#### Scenario: Meter polling is canceled on stop
- **WHEN** a test starts recording and then stops recording
- **THEN** the test SHALL assert that recording meter polling no longer updates view model meter state after stop

#### Scenario: Retry analysis cancels previous analysis
- **WHEN** a test starts retry analysis while an earlier analysis task is still in flight
- **THEN** the test SHALL assert that the earlier analysis result cannot replace the newer analysis result

#### Scenario: Teardown cancels in-flight analysis
- **WHEN** a test calls the recording view model teardown hook while analysis is in flight
- **THEN** the test SHALL assert that the canceled analysis does not transition to suggestions or an analysis error caused only by cancellation

#### Scenario: Teardown stops active recording
- **WHEN** a test calls the recording view model teardown hook while recording is active
- **THEN** the test SHALL assert that the audio recorder is stopped
- **THEN** the test SHALL assert that meter polling is canceled
