## ADDED Requirements

### Requirement: Check-in flow presents calm recovery states

The system SHALL present beta-ready recovery states for recoverable check-in failures using plain language, a specific next action, and calm visual treatment.

#### Scenario: Microphone permission recovery opens Settings
- **WHEN** the user has denied microphone permission
- **THEN** the system SHALL display a recovery state explaining that microphone access is needed to record a check-in
- **THEN** the recovery state SHALL provide an "Open Settings" action
- **THEN** activating "Open Settings" SHALL request opening the app's system Settings page
- **THEN** the recovery state SHALL provide a way to try microphone permission again after the user returns

#### Scenario: Model loading recovery
- **WHEN** the WhisperKit model fails to download or load
- **THEN** the system SHALL display a recovery state explaining that Sift could not prepare speech recognition
- **THEN** the recovery state SHALL reassure the user that nothing was lost
- **THEN** the recovery state SHALL provide a retry action for model loading

#### Scenario: Empty speech recovery
- **WHEN** transcription completes with empty or whitespace-only text
- **THEN** the system SHALL display a recovery state explaining that the check-in did not come through
- **THEN** the recovery state SHALL reassure the user that they did not do anything wrong
- **THEN** the recovery state SHALL provide a "Record again" action that returns the user to the ready recording state

#### Scenario: Analysis failure recovery preserves transcript
- **WHEN** recommendation analysis fails after a transcript has been created
- **THEN** the system SHALL display a recovery state explaining that suggestions did not load
- **THEN** the recovery state SHALL state that the check-in text is still available
- **THEN** the recovery state SHALL provide a retry action for suggestions
- **THEN** retrying suggestions SHALL reuse the existing transcript instead of asking the user to record again

#### Scenario: Empty suggestion recovery
- **WHEN** analysis completes but no usable practices can be shown
- **THEN** the system SHALL display a recovery state explaining that Sift could not find practices to show this time
- **THEN** the recovery state SHALL avoid implying that the user checked in incorrectly
- **THEN** the recovery state SHALL provide a retry action for suggestions

#### Scenario: Recovery states remain calm
- **WHEN** the system displays a recoverable check-in failure
- **THEN** the recovery state SHALL avoid raw technical error text as the primary user-facing message
- **THEN** the recovery state SHALL avoid visually alarming red treatment for non-emergency failures
