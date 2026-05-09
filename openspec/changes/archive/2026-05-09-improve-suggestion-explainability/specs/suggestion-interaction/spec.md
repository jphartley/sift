## MODIFIED Requirements

### Requirement: Practice cards use accordion pattern with separate commit action

The system SHALL present practice cards as expandable items. A collapsed card SHALL show the practice name, category badge, duration, previously-helpful badge (if applicable), and the first two lines of the summary. An expanded card SHALL additionally show the full summary text, full relevance text under the label "Why this might help", and a "Try This" button. Only one card MAY be expanded at a time. Tapping "Try This" SHALL open a practice detail page and SHALL NOT record a practice attempt.

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
- **THEN** the relevance text SHALL NOT be visible

#### Scenario: Expanded card shows full text
- **WHEN** a practice card is in its expanded state
- **THEN** the summary SHALL be fully visible with no line limit
- **THEN** the relevance text (if available) SHALL be fully visible with no line limit under the label "Why this might help"

### Requirement: Practice detail page presents actionable practice content

The system SHALL show a practice detail page after the user selects a recommended practice. The page SHALL present the selected practice's name, category, estimated duration, relevance text when available, summary, numbered practice steps under the heading "One way to practice", and why-it-helps explanation.

#### Scenario: Practice detail shows core content
- **WHEN** the user opens the practice detail page for a recommended practice
- **THEN** the page SHALL show the practice name, category, and estimated duration
- **THEN** the page SHALL show the relevance text when available
- **THEN** the page SHALL show the practice summary
- **THEN** the page SHALL show practice steps as a numbered list under "One way to practice"
- **THEN** the page SHALL show the why-it-helps explanation

#### Scenario: Practice detail allows adaptation
- **WHEN** the practice detail page renders the practice steps
- **THEN** the steps section heading SHALL be "One way to practice"
- **THEN** the page SHALL NOT present the steps as the only valid way to do the practice

## ADDED Requirements

### Requirement: Suggestion screen explains recommendations in human-facing language

The system SHALL explain suggested practices using soft, human-facing coaching language. The main suggestion UI SHALL avoid provider names, model names, confidence scores, routing terms, and debug language.

#### Scenario: Suggestion rationale uses coaching label
- **WHEN** the suggestion screen displays recommendation rationale
- **THEN** the rationale SHALL be shown under the label "Why these might fit"
- **THEN** the rationale SHALL be visible before the practice cards
- **THEN** the rationale label SHALL NOT be "Analysis"

#### Scenario: Expanded relevance uses coaching label
- **WHEN** the user expands a recommended practice card with relevance text
- **THEN** the card SHALL show the relevance text under the label "Why this might help"
- **THEN** the relevance label SHALL avoid provider, model, confidence, routing, and debug terms

#### Scenario: Model escalation is hidden from main suggestion UI
- **WHEN** recommendations were produced after model escalation
- **THEN** the main suggestion UI SHALL NOT display "Escalated to Pro model"
- **THEN** the main suggestion UI SHALL NOT display model-routing or confidence details
