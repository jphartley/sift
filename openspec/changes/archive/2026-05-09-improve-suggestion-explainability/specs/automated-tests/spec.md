## ADDED Requirements

### Requirement: Tests cover suggestion explainability copy

The system SHALL have automated tests verifying that the suggestion experience exposes rationale and relevance in human-facing coaching language while hiding model-routing implementation details.

#### Scenario: Rationale label is covered
- **WHEN** automated tests exercise suggestion view presentation data or the suggestion view
- **THEN** the tests SHALL verify that the rationale label is "Why these might fit"
- **THEN** the tests SHALL verify that the old label "Analysis" is not used for the suggestion rationale

#### Scenario: Relevance label is covered
- **WHEN** automated tests exercise expanded practice card presentation data or the expanded practice card
- **THEN** the tests SHALL verify that relevance text is associated with the label "Why this might help"
- **THEN** the tests SHALL verify that relevance text remains available when a practice has relevance copy

#### Scenario: Model-routing details are hidden from beta-facing suggestion UI
- **WHEN** automated tests exercise suggestion presentation for an escalated recommendation result
- **THEN** the tests SHALL verify that the main suggestion UI copy does not include "Escalated to Pro model"
- **THEN** the tests SHALL verify that the main suggestion UI copy avoids provider names, model names, confidence scores, routing terms, and debug language

#### Scenario: Internal routing behavior remains covered separately
- **WHEN** automated tests exercise Gemini routing and RecordingViewModel recommendation state
- **THEN** existing tests SHALL continue to verify Flash-to-Pro escalation behavior and internal escalation state without depending on a user-facing escalation toast
