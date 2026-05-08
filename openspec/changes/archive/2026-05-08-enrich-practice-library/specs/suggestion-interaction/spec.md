## MODIFIED Requirements

### Requirement: Practice cards use accordion pattern with separate commit action

The system SHALL present practice cards as expandable items. A collapsed card SHALL show the practice name, category badge, duration, previously-helpful badge (if applicable), and the first two lines of the practice summary. An expanded card SHALL additionally show the full summary text, full Gemini relevance text, and a "Try This" button. Only one card MAY be expanded at a time.

#### Scenario: Tapping a collapsed card expands it
- **WHEN** the user taps a collapsed practice card
- **THEN** the card SHALL expand to show its full summary and relevance text
- **THEN** a "Try This" button SHALL appear inside the expanded card
- **THEN** any previously expanded card SHALL collapse

#### Scenario: Tapping the expanded card collapses it
- **WHEN** the user taps the currently expanded practice card (not the "Try This" button)
- **THEN** the card SHALL collapse to its compact form
- **THEN** no card SHALL be expanded

#### Scenario: Tapping "Try This" commits the practice selection
- **WHEN** the user taps the "Try This" button inside an expanded practice card
- **THEN** the system SHALL transition to the reflection screen for that practice

#### Scenario: Collapsed card shows preview text
- **WHEN** a practice card is in its collapsed state
- **THEN** the summary SHALL be limited to 2 lines
- **THEN** the Gemini relevance text SHALL NOT be visible

#### Scenario: Expanded card shows full text
- **WHEN** a practice card is in its expanded state
- **THEN** the summary SHALL be fully visible with no line limit
- **THEN** the Gemini relevance text (if available) SHALL be fully visible with no line limit

### Requirement: Reflection screen shows practice context

The system SHALL display the selected practice's summary and Gemini relevance text on the reflection screen before asking whether the user tried the practice.

#### Scenario: Reflection screen loads with practice details
- **WHEN** the system transitions to the reflection screen for a selected practice
- **THEN** the practice name, full summary, and relevance text SHALL be visible
- **THEN** the "Did you try [practice name]?" question SHALL appear below the practice details

#### Scenario: Practice with no relevance text still shows details
- **WHEN** the selected practice has no Gemini relevance text available
- **THEN** the practice name and full summary SHALL still be displayed
- **THEN** the relevance section SHALL be omitted without error
