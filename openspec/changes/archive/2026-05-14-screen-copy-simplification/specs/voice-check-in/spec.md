## MODIFIED Requirements

### Requirement: First-time setup preserves trust during speech preparation

The system SHALL present first-time setup copy in calm, plain language so users understand why they cannot record yet. The loading screen SHALL display the title and footer note only — the inline subtitle explaining on-device speech recognition SHALL NOT be shown.

#### Scenario: Downloading model shows progress and context
- **WHEN** the speech model is downloading
- **THEN** the setup presentation SHALL show determinate progress
- **THEN** the setup presentation SHALL show the title "Getting Sift ready"
- **THEN** the setup presentation SHALL show the footer note that first setup can take a little while
- **THEN** the setup presentation SHALL NOT display an inline subtitle beneath the title
- **THEN** the setup presentation SHALL avoid prototype terms such as "speech model"

#### Scenario: Preparing model shows active state and context
- **WHEN** the speech model has downloaded and is being prepared locally
- **THEN** the setup presentation SHALL show an active indeterminate loading state
- **THEN** the setup presentation SHALL show the title "Getting Sift ready"
- **THEN** the setup presentation SHALL show the footer note that first setup can take a little while
- **THEN** the setup presentation SHALL NOT display an inline subtitle beneath the title

#### Scenario: Ready state replaces setup
- **WHEN** speech recognition is ready
- **THEN** the setup presentation SHALL no longer be visible
- **THEN** the regular ready check-in orientation SHALL be visible

### Requirement: Ready check-in screen orients users

The system SHALL display first-screen orientation in the ready recording state so users understand how to begin a voice check-in without external explanation. The orientation SHALL be presented as a single concise paragraph and a "For example:" list of starter prompts.

#### Scenario: Ready state explains how to check in
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL display the heading "Take a moment to arrive"
- **THEN** the system SHALL NOT display a separate date or time label above the heading
- **THEN** the system SHALL display a single orientation paragraph inviting the user to speak for about a minute about what feels most alive right now
- **THEN** the orientation paragraph SHALL mention examples: what happened, how it feels, or what kind of support the user wants
- **THEN** the orientation paragraph SHALL explain that Sift will reflect back what it heard and suggest a few practices to choose from
- **THEN** the system SHALL NOT display a separate second paragraph for the "what happens next" explanation

#### Scenario: Ready state offers starter prompts as a plain list
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL display a "For example:" label followed by the starter prompts
- **THEN** the starter prompts SHALL be rendered as plain italic text with no border, background, or tappable styling
- **THEN** the starter prompts SHALL include "Right now I notice...", "What feels hard is...", and "What I need is..."

#### Scenario: Ready state preserves recording action
- **WHEN** the recording screen is in the ready state
- **THEN** the system SHALL keep the microphone recording action available as the primary action
- **THEN** tapping the recording action SHALL continue to start recording

#### Scenario: Returning ready state uses simpler guidance
- **WHEN** the recording screen is in the ready state after a previous transcript is available
- **THEN** the system SHALL display the heading "Check in again"
- **THEN** the system SHALL display the guidance "Record another short voice note about what feels most alive right now. A minute is enough."
- **THEN** the system SHALL omit starter prompts from the returning ready state

### Requirement: Recording state presents minimal UI

The system SHALL display a minimal recording UI so the user can focus on speaking without distraction.

#### Scenario: Recording in progress shows minimal text
- **WHEN** the system is in the recording state
- **THEN** the system SHALL display "Take your time." as the only text above the waveform
- **THEN** the system SHALL NOT display a "LISTENING" status label
- **THEN** the system SHALL NOT display "I'm here." text
- **THEN** the system SHALL NOT display a privacy note below the stop button

#### Scenario: Recording in progress shows waveform and stop action
- **WHEN** the system is in the recording state
- **THEN** the system SHALL display a live audio waveform visualization
- **THEN** the system SHALL display a "Stop" button to end recording

### Requirement: Analyzing state presents minimal UI

The system SHALL display a minimal analyzing UI that focuses attention on the loading state without supplementary copy.

#### Scenario: Analyzing state shows title only
- **WHEN** the system is in the analyzing state
- **THEN** the system SHALL display "Reading what you shared"
- **THEN** the system SHALL NOT display a subtitle beneath the title
- **THEN** the system SHALL display the transcript text when available

### Requirement: Suggestion screen prioritises rationale over transcript

The suggestion screen SHALL visually prioritise the "Why these might fit" rationale over the "YOU SHARED" transcript so users encounter the most useful content first.

#### Scenario: Transcript is displayed as secondary content
- **WHEN** the suggestion screen is displayed
- **THEN** the transcript SHALL be rendered in a visually secondary style (muted/quiet color)
- **THEN** the rationale heading "Why these might fit" SHALL use a prominent heading font
- **THEN** the rationale text SHALL use the primary ink color

#### Scenario: Memory insert card is not shown
- **WHEN** the suggestion screen is displayed regardless of prior session history
- **THEN** the system SHALL NOT display a "WHAT I REMEMBER" memory insert card

#### Scenario: Skip button is clearly active
- **WHEN** the suggestion screen is displayed
- **THEN** the skip/done button SHALL display the label "I'm good for now"
- **THEN** the button SHALL be styled to appear clearly interactive and active

### Requirement: Reflection screen presents minimal header

The reflection screen SHALL display only the question heading without a preceding status label.

#### Scenario: Reflection screen shows question only
- **WHEN** the reflection screen is displayed
- **THEN** the system SHALL display "How did that land?" as the heading
- **THEN** the system SHALL NOT display an "AFTER" label above the heading

#### Scenario: Reflection notes placeholder is welcoming
- **WHEN** the reflection notes field is empty
- **THEN** the placeholder text SHALL read "(Optional) anything else you want to share..."
