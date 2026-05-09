## ADDED Requirements

### Requirement: Tests cover Privacy tab and trust copy

The system SHALL have automated tests verifying that the Privacy tab exists and exposes the core privacy/trust copy.

#### Scenario: Privacy tab is covered
- **WHEN** automated UI or view-adjacent tests exercise the main tab interface
- **THEN** the tests SHALL verify that a "Privacy" tab is available

#### Scenario: Privacy copy is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that audio-on-phone handling is represented
- **THEN** the tests SHALL verify that transcript-to-Gemini handling is represented
- **THEN** the tests SHALL verify that local history and deletion are represented
- **THEN** the tests SHALL verify that developer access limits are represented
- **THEN** the tests SHALL verify that Jeremy Hartley and `jphartley@gmail.com` are represented

#### Scenario: AI suggestion disclosure is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that Sift does not attach the user's name, email, or account to Gemini requests
- **THEN** the tests SHALL verify that spoken identifying details remain part of the transcript sent to Gemini
- **THEN** the tests SHALL verify that paid Gemini API data-use language is represented

### Requirement: Tests cover sensitive logging guardrails

The system SHALL have automated tests or static checks verifying that the recommendation flow does not log sensitive check-in content.

#### Scenario: Gemini logging avoids raw response text
- **WHEN** automated tests or static checks inspect Gemini request error handling
- **THEN** they SHALL verify that raw Gemini response text is not printed to the developer console

#### Scenario: Gemini logging remains metadata-only
- **WHEN** automated tests or static checks inspect Gemini recommendation logging
- **THEN** they SHALL allow non-sensitive metadata such as model names, prompt length, history count, confidence, escalation state, and practice IDs
- **THEN** they SHALL reject logging of transcript text, full prompt text, or raw response text
