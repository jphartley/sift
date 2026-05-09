## ADDED Requirements

### Requirement: Tests cover calm recovery presentation

The system SHALL have automated tests verifying that recoverable check-in failures map to calm, action-specific recovery presentation.

#### Scenario: Microphone Settings action is covered
- **WHEN** automated tests exercise microphone permission denial
- **THEN** the tests SHALL verify that the recovery presentation explains microphone access is needed
- **THEN** the tests SHALL verify that an "Open Settings" action is available
- **THEN** the tests SHALL verify that the Settings action targets the app's system Settings page

#### Scenario: Model loading recovery is covered
- **WHEN** automated tests exercise model loading failure presentation
- **THEN** the tests SHALL verify that the recovery presentation explains Sift could not prepare speech recognition
- **THEN** the tests SHALL verify that the presentation includes a retry action
- **THEN** the tests SHALL verify that the presentation reassures the user that nothing was lost

#### Scenario: Empty speech recovery is covered
- **WHEN** automated tests exercise empty or whitespace-only transcription output
- **THEN** the tests SHALL verify that the flow does not continue into recommendation analysis
- **THEN** the tests SHALL verify that the recovery presentation says the check-in did not come through
- **THEN** the tests SHALL verify that the presentation offers recording again

#### Scenario: Analysis failure recovery is covered
- **WHEN** automated tests exercise recommendation analysis failure after transcription
- **THEN** the tests SHALL verify that the pending transcript remains available
- **THEN** the tests SHALL verify that the recovery presentation says suggestions did not load
- **THEN** the tests SHALL verify that retrying suggestions reuses the existing transcript

#### Scenario: Empty suggestion recovery is covered
- **WHEN** automated tests exercise an analysis result with no usable practices
- **THEN** the tests SHALL verify that the recovery presentation avoids blaming the user
- **THEN** the tests SHALL verify that a retry suggestions action is available
