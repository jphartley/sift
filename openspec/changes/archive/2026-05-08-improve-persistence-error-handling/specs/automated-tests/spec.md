## ADDED Requirements

### Requirement: Tests cover history deletion persistence behavior
The system SHALL have automated tests for history deletion success and failure paths using a testable persistence boundary or history state owner.

#### Scenario: History deletion calls persistence boundary
- **WHEN** a test deletes a session from history
- **THEN** the test SHALL assert the selected session is passed to the persistence boundary for deletion

#### Scenario: History deletion failure is surfaced
- **WHEN** the persistence boundary throws while deleting a session from history
- **THEN** the test SHALL assert the history flow records a user-visible error state

#### Scenario: SwiftData cascade deletion remains covered
- **WHEN** a Session with PracticeAttempts is deleted through the real SwiftData-backed store or existing in-memory SwiftData coverage
- **THEN** the test SHALL assert associated PracticeAttempts are removed
