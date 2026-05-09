## ADDED Requirements

### Requirement: Ready check-in screen orients users

The system SHALL display first-screen orientation in the ready recording state so users understand how to begin a voice check-in without external explanation.

#### Scenario: Ready state explains how to check in
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL display the heading "Take a moment to arrive"
- **THEN** the system SHALL state that there is no right or wrong way to check in
- **THEN** the system SHALL invite the user to speak for about a minute about what feels most alive right now
- **THEN** the system SHALL mention examples of useful check-in content, including what happened, how it feels, or what kind of support the user wants

#### Scenario: Ready state explains what happens next
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL explain that Sift transcribes the user's voice on device
- **THEN** the system SHALL explain that Sift reflects back what it heard
- **THEN** the system SHALL explain that Sift suggests practices the user can choose from

#### Scenario: Ready state offers starter prompts
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL display starter prompts that help users begin speaking
- **THEN** the starter prompts SHALL include "Right now I notice...", "What feels hard is...", and "What I need is..."

#### Scenario: Ready state preserves recording action
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL keep the microphone recording action available as the primary action
- **THEN** tapping the recording action SHALL continue to start recording

#### Scenario: Returning ready state uses simpler guidance
- **WHEN** the recording screen is in the ready state after a previous transcript is available
- **THEN** the system SHALL display the heading "Check in again"
- **THEN** the system SHALL display the guidance "Record another short voice note about what feels most alive right now. A minute is enough."
- **THEN** the system SHALL use the shorter repeat instruction instead of the full first-time orientation
- **THEN** the system SHALL omit starter prompts from the returning ready state
- **THEN** the system SHALL continue to show the previous transcript for context

#### Scenario: Check-in flow omits persistent navigation title
- **WHEN** the user is in the recording check-in flow
- **THEN** the system SHALL NOT display a persistent "Check In" navigation title above the flow content
