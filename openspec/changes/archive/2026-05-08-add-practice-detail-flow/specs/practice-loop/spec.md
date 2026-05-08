## MODIFIED Requirements

### Requirement: User can log a practice attempt

The system SHALL allow the user to mark a suggested practice as completed. Each attempt SHALL be associated with the current session. Opening a practice detail page SHALL NOT log an attempt; tapping "I did this" from the practice detail page SHALL log the attempt.

#### Scenario: User opens practice detail
- **WHEN** the user taps "Try This" for a suggested practice
- **THEN** the system SHALL present a practice detail page for that practice
- **THEN** the system SHALL NOT log a PracticeAttempt

#### Scenario: User marks practice as done
- **WHEN** the user taps "I did this" on the practice detail page
- **THEN** the system SHALL create a PracticeAttempt associated with the current session
- **THEN** the system SHALL prompt the user to rate whether the practice was helpful

#### Scenario: User returns without completing practice
- **WHEN** the user returns from the practice detail page to the suggestion list without tapping "I did this"
- **THEN** the system SHALL return to the practice suggestion list without logging an attempt

### Requirement: User can rate practice helpfulness

After marking a practice as completed, the system SHALL allow the user to rate whether the practice was helpful (thumbs up) or not helpful (thumbs down).

#### Scenario: User rates practice as helpful
- **WHEN** the user taps thumbs up
- **THEN** the system SHALL persist the PracticeAttempt with `wasHelpful: true`

#### Scenario: User rates practice as not helpful
- **WHEN** the user taps thumbs down
- **THEN** the system SHALL persist the PracticeAttempt with `wasHelpful: false`

#### Scenario: User skips rating
- **WHEN** the user dismisses the reflection without rating
- **THEN** the system SHALL persist the PracticeAttempt with `wasHelpful: nil` and return to the ready state
