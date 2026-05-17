## ADDED Requirements

### Requirement: Debug metrics screen exposes an onboarding reset section

The system SHALL display a dedicated "Onboarding" section in `DebugMetricsScreen` containing a "Reset onboarding" button. The section SHALL appear below the experiments and metrics content. The button SHALL be enabled at all times regardless of whether any `UserPracticeProfile` records exist. Tapping the button SHALL present a confirmation dialog before any deletion is performed.

#### Scenario: User views the debug metrics screen

- **WHEN** the user opens the Debug tab
- **THEN** the system SHALL display an "Onboarding" section containing a "Reset onboarding" button
- **THEN** the button SHALL be enabled regardless of current profile state

#### Scenario: User taps Reset onboarding

- **WHEN** the user taps the "Reset onboarding" button
- **THEN** the system SHALL present a confirmation dialog asking "Reset onboarding?"
- **THEN** the dialog SHALL include a destructive "Reset" action and a "Cancel" action
