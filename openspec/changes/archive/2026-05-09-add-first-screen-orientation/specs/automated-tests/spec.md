## ADDED Requirements

### Requirement: Tests cover ready-screen orientation

The system SHALL have automated tests verifying that the ready recording screen exposes the first-screen orientation expected for internal beta readiness.

#### Scenario: Orientation copy is test-covered
- **WHEN** automated tests exercise the ready recording screen or its view-adjacent presentation data
- **THEN** the tests SHALL verify that the orientation includes the heading "Take a moment to arrive"
- **THEN** the tests SHALL verify that the orientation includes "There is no right or wrong way to do this"
- **THEN** the tests SHALL verify that the orientation includes "what feels most alive right now"
- **THEN** the tests SHALL verify that the starter prompts are exposed

#### Scenario: Existing voice check-in behavior remains covered
- **WHEN** automated tests run after the orientation change
- **THEN** existing tests for recording setup, recording start, transcription, recommendation, persistence, and cancellation SHALL continue to pass

#### Scenario: Returning guidance is test-covered
- **WHEN** automated tests exercise the ready recording screen presentation data
- **THEN** the tests SHALL verify that the returning heading is "Check in again"
- **THEN** the tests SHALL verify that the returning guidance includes "Record another short voice note", "what feels most alive right now", and "A minute is enough"
- **THEN** the tests SHALL verify that first-time starter prompts remain separate from returning guidance
