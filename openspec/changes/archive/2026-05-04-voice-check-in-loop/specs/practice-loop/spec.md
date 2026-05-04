## ADDED Requirements

### Requirement: System maintains a curated practice library

The system SHALL include a hardcoded library of wellness practices. Each practice SHALL have an identifier, name, category, keywords for matching, a description, and an estimated duration.

#### Scenario: Practice data is available
- **WHEN** the app loads
- **THEN** all practices in the library SHALL be accessible for suggestion matching and display

### Requirement: User can log a practice attempt

The system SHALL allow the user to mark a suggested practice as completed or not completed. Each attempt SHALL be associated with the current session.

#### Scenario: User marks practice as done
- **WHEN** the user taps a practice card from the suggestion list
- **THEN** the system SHALL present a reflection view asking the user to confirm they tried the practice

#### Scenario: User confirms they tried the practice
- **WHEN** the user taps "Yes, I tried it"
- **THEN** the system SHALL prompt the user to rate whether the practice was helpful

#### Scenario: User did not try the practice
- **WHEN** the user taps "No, I didn't try it"
- **THEN** the system SHALL return to the practice suggestion list without logging an attempt

### Requirement: User can rate practice helpfulness

After confirming they tried a practice, the system SHALL allow the user to rate whether the practice was helpful (thumbs up) or not helpful (thumbs down).

#### Scenario: User rates practice as helpful
- **WHEN** the user taps thumbs up
- **THEN** the system SHALL persist the PracticeAttempt with `wasHelpful: true`

#### Scenario: User rates practice as not helpful
- **WHEN** the user taps thumbs down
- **THEN** the system SHALL persist the PracticeAttempt with `wasHelpful: false`

#### Scenario: User skips rating
- **WHEN** the user dismisses the reflection without rating
- **THEN** the system SHALL persist the PracticeAttempt with `wasHelpful: nil` and return to the ready state

### Requirement: User can add optional reflection notes

After completing a practice, the system SHALL allow the user to add an optional free-text note about their experience.

#### Scenario: User adds a note
- **WHEN** the user enters text in the notes field and saves
- **THEN** the system SHALL persist the note with the PracticeAttempt

### Requirement: System persists sessions with practice attempts

The system SHALL persist each check-in session and its associated practice attempts using SwiftData. Each session SHALL include a timestamp, transcript text, audio duration, and transcription duration.

#### Scenario: Session saved with practice attempt
- **WHEN** the user completes a practice reflection
- **THEN** the system SHALL persist both the Session and the PracticeAttempt

#### Scenario: Session saved after transcription with no practice attempted
- **WHEN** the user returns to ready state without trying any practice
- **THEN** the system SHALL persist the Session without any associated PracticeAttempts

### Requirement: User can view session history

The system SHALL display a list of past sessions in reverse chronological order. Each session SHALL show the date, a preview of the transcript, and the practices attempted (with helpfulness ratings).

#### Scenario: History is empty
- **WHEN** no sessions have been recorded
- **THEN** the system SHALL display an empty state message

#### Scenario: History shows past sessions
- **WHEN** one or more sessions exist
- **THEN** the system SHALL display each session with date, transcript preview, and practice attempts with their helpfulness status

### Requirement: User can delete sessions

The system SHALL allow the user to delete a session and all its associated practice attempts from history.

#### Scenario: User deletes a session
- **WHEN** the user swipes to delete a session from history
- **THEN** the system SHALL remove the session and all its associated PracticeAttempts
