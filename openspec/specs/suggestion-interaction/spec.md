## Purpose
Define how practice suggestion and reflection screens behave when users review recommendations, expand practice details, choose a practice, or navigate back.
## Requirements
### Requirement: Practice cards use accordion pattern with separate commit action

The system SHALL present practice cards as expandable items. A collapsed card SHALL show the practice name, category badge, duration, previously-helpful badge (if applicable), and the first two lines of the summary. An expanded card SHALL additionally show the full summary text, full Gemini relevance text, and a "Try This" button. Only one card MAY be expanded at a time. Tapping "Try This" SHALL open a practice detail page and SHALL NOT record a practice attempt.

#### Scenario: Tapping a collapsed card expands it
- **WHEN** the user taps a collapsed practice card
- **THEN** the card SHALL expand to show its full summary and relevance text
- **THEN** a "Try This" button SHALL appear inside the expanded card
- **THEN** any previously expanded card SHALL collapse

#### Scenario: Tapping the expanded card collapses it
- **WHEN** the user taps the currently expanded practice card (not the "Try This" button)
- **THEN** the card SHALL collapse to its compact form
- **THEN** no card SHALL be expanded

#### Scenario: Tapping "Try This" opens practice detail
- **WHEN** the user taps the "Try This" button inside an expanded practice card
- **THEN** the system SHALL transition to a practice detail page for that practice
- **THEN** the system SHALL NOT record a PracticeAttempt

#### Scenario: Collapsed card shows preview text
- **WHEN** a practice card is in its collapsed state
- **THEN** the summary SHALL be limited to 2 lines
- **THEN** the Gemini relevance text SHALL NOT be visible

#### Scenario: Expanded card shows full text
- **WHEN** a practice card is in its expanded state
- **THEN** the summary SHALL be fully visible with no line limit
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

The system SHALL display minimal context for the selected completed practice on the reflection screen before asking whether the practice helped.

#### Scenario: Reflection screen loads with minimal practice context
- **WHEN** the system transitions to the reflection screen after the user taps "I did this"
- **THEN** the practice name SHALL be visible
- **THEN** the reflection screen SHALL ask whether the practice helped
- **THEN** the reflection screen SHALL NOT ask whether the user tried the practice

#### Scenario: Practice with no relevance text still shows reflection
- **WHEN** the selected practice has no Gemini relevance text available
- **THEN** the reflection screen SHALL still display the practice name and helpfulness controls

### Requirement: Back navigation from reflection phase one

The system SHALL provide a way to return from the practice detail page to the suggestion screen without falsely claiming the practice was tried.

#### Scenario: Back button returns from practice detail to suggestion screen
- **WHEN** the user taps the "Back" button on the practice detail page
- **THEN** the system SHALL return to the suggestion screen
- **THEN** the recommendation data SHALL be preserved
- **THEN** no practice attempt SHALL be recorded

#### Scenario: Reflection screen has no try-confirmation back phase
- **WHEN** the user has tapped "I did this" from the practice detail page
- **THEN** the system SHALL show helpfulness reflection
- **THEN** the old "Did you try...?" confirmation phase SHALL NOT be visible

### Requirement: Practice detail page presents actionable practice content

The system SHALL show a practice detail page after the user selects a recommended practice. The page SHALL present the selected practice's name, category, estimated duration, Gemini relevance text when available, summary, numbered practice steps under the heading "One way to practice", and why-it-helps explanation.

#### Scenario: Practice detail shows core content
- **WHEN** the user opens the practice detail page for a recommended practice
- **THEN** the page SHALL show the practice name, category, and estimated duration
- **THEN** the page SHALL show the Gemini relevance text when available
- **THEN** the page SHALL show the practice summary
- **THEN** the page SHALL show practice steps as a numbered list under "One way to practice"
- **THEN** the page SHALL show the why-it-helps explanation

#### Scenario: Practice detail allows adaptation
- **WHEN** the practice detail page renders the practice steps
- **THEN** the steps section heading SHALL be "One way to practice"
- **THEN** the page SHALL NOT present the steps as the only valid way to do the practice

### Requirement: Practice detail page has sticky completion action

The system SHALL keep an always-enabled "I did this" action visible in a sticky bottom safe-area container on the practice detail page.

#### Scenario: Completion action is visible
- **WHEN** the user opens the practice detail page
- **THEN** the "I did this" action SHALL be available without requiring the user to scroll to the bottom

#### Scenario: Completion action records attempt and opens reflection
- **WHEN** the user taps "I did this"
- **THEN** the system SHALL record a PracticeAttempt for the selected practice
- **THEN** the system SHALL transition to the helpfulness reflection screen

### Requirement: Practice detail page shows calm safety note when needed

The system SHALL show a subtle, non-red safety note when the selected practice has non-empty avoid-when guidance or high intensity. The note SHALL use soft, relational language that reminds users they can go slowly, adapt, or stop. The note SHALL be omitted for low and medium intensity practices with no avoid-when guidance.

#### Scenario: Practice has avoid-when guidance
- **WHEN** the selected practice has one or more avoid-when values
- **THEN** the practice detail page SHALL show a calm note containing those values
- **THEN** the note SHALL communicate that the user can adapt or stop the practice

#### Scenario: Practice is high intensity
- **WHEN** the selected practice has high intensity
- **THEN** the practice detail page SHALL show a calm note indicating that it is a higher-intensity practice
- **THEN** the note SHALL tell the user to go slowly
- **THEN** the note SHALL communicate that the user can adapt or stop the practice

#### Scenario: Practice has no note-worthy guidance
- **WHEN** the selected practice is low or medium intensity and has no avoid-when values
- **THEN** the practice detail page SHALL omit the safety note

