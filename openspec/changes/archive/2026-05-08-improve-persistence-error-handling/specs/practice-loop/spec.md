## MODIFIED Requirements

### Requirement: User can delete sessions

The system SHALL allow the user to delete a session and all its associated practice attempts from history. The system SHALL surface persistence failures during deletion instead of silently treating the delete as successful.

#### Scenario: User deletes a session
- **WHEN** the user swipes to delete a session from history
- **THEN** the system SHALL remove the session and all its associated PracticeAttempts

#### Scenario: Session deletion fails
- **WHEN** the user swipes to delete a session from history and persistence fails
- **THEN** the system SHALL display a user-visible error message
- **THEN** the system SHALL NOT silently dismiss the failure as a successful delete
