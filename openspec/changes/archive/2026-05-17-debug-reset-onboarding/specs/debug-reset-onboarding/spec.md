## ADDED Requirements

### Requirement: Debug reset onboarding action deletes all user practice profiles

The system SHALL provide a "Reset onboarding" action in the debug metrics screen that, when confirmed, deletes every `UserPracticeProfile` record from SwiftData. No other SwiftData entities (`Session`, `PracticeAttempt`, `MetricEvent`) SHALL be affected. The action SHALL be guarded by a confirmation dialog before any deletion occurs.

#### Scenario: User taps Reset onboarding and confirms

- **WHEN** the user taps "Reset onboarding" in the debug metrics screen
- **AND** the user confirms the action in the confirmation dialog
- **THEN** the system SHALL delete every `UserPracticeProfile` record from SwiftData
- **THEN** the system SHALL leave all `Session`, `PracticeAttempt`, and `MetricEvent` records unchanged

#### Scenario: User taps Reset onboarding and cancels

- **WHEN** the user taps "Reset onboarding" in the debug metrics screen
- **AND** the user cancels the confirmation dialog
- **THEN** the system SHALL NOT delete any records
- **THEN** the system SHALL dismiss the confirmation dialog and return to the debug metrics screen

#### Scenario: Intake gate reactivates automatically after reset

- **WHEN** all `UserPracticeProfile` records are deleted
- **THEN** `IntakeGate.shouldShowIntake` SHALL return `true` because the profiles query result is empty
- **THEN** `ContentView` SHALL display `IntakeScreen` without requiring any explicit navigation

#### Scenario: Reset is only available in Debug builds

- **WHEN** the app is built in Release configuration
- **THEN** the "Reset onboarding" action SHALL NOT be present anywhere in the app
