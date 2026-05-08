## ADDED Requirements

### Requirement: Tests cover safe secret fallback behavior
The system SHALL have automated coverage proving Gemini API key setup remains safe and explicit.

#### Scenario: Placeholder key is accessible
- **WHEN** automated tests access `Secrets.geminiApiKey`
- **THEN** the value SHALL be available as a `String` without requiring a private local secret file

#### Scenario: Empty placeholder fails before network
- **WHEN** automated tests exercise Gemini recommendation behavior with an empty key
- **THEN** the tests SHALL assert the missing-key error is returned
- **THEN** the tests SHALL assert no Gemini model request is made
