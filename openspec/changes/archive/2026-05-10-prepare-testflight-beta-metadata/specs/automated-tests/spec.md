## ADDED Requirements

### Requirement: Tests cover TestFlight-facing app metadata

The system SHALL have automated coverage or static project checks for app metadata that external TestFlight testers and reviewers see.

#### Scenario: Display name metadata is covered
- **WHEN** automated tests or static checks inspect app target metadata
- **THEN** they SHALL verify that the app display name is "Sift"

#### Scenario: Microphone usage description metadata is covered
- **WHEN** automated tests or static checks inspect app target metadata
- **THEN** they SHALL verify that the microphone usage description mentions voice check-ins
- **THEN** they SHALL verify that the microphone usage description mentions on-device transcription
- **THEN** they SHALL verify that the microphone usage description does not contain prototype wording such as voice samples or speech-to-text evaluation

#### Scenario: Version metadata is covered
- **WHEN** automated tests or static checks inspect app target metadata
- **THEN** they SHALL verify that the app target has explicit marketing version and current project version values
