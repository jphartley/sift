## MODIFIED Requirements

### Requirement: Session persistence is abstracted behind a store
The system SHALL route session saving, recommendation history retrieval, and history deletion through a session store boundary instead of direct SwiftData calls in the check-in view model or history UI.

#### Scenario: View model requests recommendation history
- **WHEN** the check-in flow needs prior sessions for recommendation context
- **THEN** the view model SHALL request history from the session store
- **THEN** the view model SHALL NOT construct SwiftData fetch descriptors directly

#### Scenario: View model persists completed session
- **WHEN** the user completes reflection or skips suggestions
- **THEN** the view model SHALL ask the session store to save the pending session
- **THEN** save failures SHALL be observable by the view model

#### Scenario: History deletes sessions through store
- **WHEN** the history flow deletes one or more sessions
- **THEN** the history flow SHALL ask the session store to delete the selected sessions
- **THEN** delete failures SHALL be observable by the history flow
