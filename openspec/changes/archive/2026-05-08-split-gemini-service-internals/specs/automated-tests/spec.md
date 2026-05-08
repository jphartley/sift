## ADDED Requirements

### Requirement: Tests cover Gemini collaborators without live network
The system SHALL have automated tests for Gemini prompt construction, response parsing, retry classification, and Flash/Pro routing that do not make live Gemini network requests.

#### Scenario: Prompt builder tests run without Gemini SDK requests
- **WHEN** automated tests verify prompt content
- **THEN** the tests SHALL instantiate the prompt builder directly or through non-network collaborators
- **THEN** the tests SHALL NOT require a Gemini API key or live network access

#### Scenario: Parser tests use deterministic JSON strings
- **WHEN** automated tests verify Gemini response parsing
- **THEN** the tests SHALL provide deterministic JSON strings for valid, malformed, missing-field, and empty-practices cases
- **THEN** the tests SHALL assert the resulting recommendation data or Gemini error behavior

#### Scenario: Routing tests use fake model requests
- **WHEN** automated tests verify Flash/Pro routing
- **THEN** the tests SHALL use fake model request behavior for Flash and Pro responses
- **THEN** the tests SHALL assert whether Pro was requested for high confidence, low confidence, retryable Flash failure, and non-retryable Flash failure

### Requirement: Existing Gemini service tests remain behavior-focused
The system SHALL keep `GeminiService` tests focused on facade-level recommendation behavior and error mapping after lower-level prompt, parser, and routing tests are introduced.

#### Scenario: GeminiService facade is tested
- **WHEN** automated tests instantiate `GeminiService`
- **THEN** the tests SHALL verify externally observable recommendation-client behavior
- **THEN** collaborator-specific details SHALL be verified in collaborator tests instead of through broad service tests
