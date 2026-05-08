## Purpose
Define how practice suggestion and reflection screens behave when users review recommendations, expand practice details, choose a practice, or navigate back.

## Requirements

### Requirement: Practice cards use accordion pattern with separate commit action

The system SHALL present practice cards as expandable items. A collapsed card SHALL show the practice name, category badge, duration, previously-helpful badge (if applicable), and the first two lines of the description. An expanded card SHALL additionally show the full description text, full Gemini relevance text, and a "Try This" button. Only one card MAY be expanded at a time.

#### Scenario: Tapping a collapsed card expands it
- **WHEN** the user taps a collapsed practice card
- **THEN** the card SHALL expand to show its full description and relevance text
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
- **THEN** the description SHALL be limited to 2 lines
- **THEN** the Gemini relevance text SHALL NOT be visible

#### Scenario: Expanded card shows full text
- **WHEN** a practice card is in its expanded state
- **THEN** the description SHALL be fully visible with no line limit
- **THEN** the Gemini relevance text (if available) SHALL be fully visible with no line limit

### Requirement: Suggestion screen is scrollable

The system SHALL render the suggestion screen content inside a scroll view so that all content is accessible regardless of screen size or text length.

#### Scenario: Long content is scrollable
- **WHEN** the suggestion screen content exceeds the available viewport height
- **THEN** the user SHALL be able to scroll vertically to see all content

#### Scenario: Short content fills naturally
- **WHEN** the suggestion screen content fits within the available viewport
- **THEN** the layout SHALL fill the space naturally without forced scrolling

### Requirement: Reflection screen shows practice context

The system SHALL display the selected practice's full description and Gemini relevance text on the reflection screen before asking whether the user tried the practice.

#### Scenario: Reflection screen loads with practice details
- **WHEN** the system transitions to the reflection screen for a selected practice
- **THEN** the practice name, full description, and relevance text SHALL be visible
- **THEN** the "Did you try [practice name]?" question SHALL appear below the practice details

#### Scenario: Practice with no relevance text still shows details
- **WHEN** the selected practice has no Gemini relevance text available
- **THEN** the practice name and full description SHALL still be displayed
- **THEN** the relevance section SHALL be omitted without error

### Requirement: Back navigation from reflection phase one

The system SHALL provide a way to return from the reflection screen's first phase ("Did you try...?") to the suggestion screen without falsely claiming the practice was not tried.

#### Scenario: Back button returns to suggestion screen
- **WHEN** the user taps the "Back" button on the "Did you try...?" screen
- **THEN** the system SHALL return to the suggestion screen
- **THEN** all practice cards and data SHALL be preserved in their previous state
- **THEN** no practice attempt SHALL be recorded

#### Scenario: Back button not visible in rating phase
- **WHEN** the user has confirmed they tried the practice and is now on the rating screen
- **THEN** the "Back" button SHALL NOT be visible
