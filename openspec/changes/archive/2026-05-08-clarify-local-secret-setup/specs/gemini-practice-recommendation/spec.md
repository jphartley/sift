## MODIFIED Requirements

### Requirement: API key is stored in a gitignored source file

The system SHALL read the Gemini API key from `Secrets.geminiApiKey`. The repository SHALL provide a checked-in, debug-safe default value so the app compiles from a fresh clone without a private key. Real Gemini API keys SHALL remain excluded from version control. A committed template or first-run setup instructions SHALL explain how to configure a local key for real Gemini requests.

#### Scenario: Fresh clone builds without local key

- **WHEN** the repository is cloned without a private local secret file
- **THEN** the app SHALL still compile with a safe placeholder `Secrets.geminiApiKey` value

#### Scenario: API key is configured

- **WHEN** the developer configures a non-empty local `geminiApiKey` value
- **THEN** the system SHALL use it for Gemini API requests

#### Scenario: API key is missing

- **WHEN** `Secrets.geminiApiKey` is empty
- **THEN** the system SHALL fail at the point of the first Gemini request with an error indicating the key is missing
- **THEN** the system SHALL NOT make a Gemini network request

#### Scenario: Real key remains untracked

- **WHEN** a developer configures a real Gemini API key locally
- **THEN** the real key SHALL be excluded from version control

### Requirement: Local Gemini setup is documented

The system SHALL include first-run developer documentation that explains how local Gemini API key setup works.

#### Scenario: Developer reads setup docs

- **WHEN** a developer follows the first-run setup documentation
- **THEN** they SHALL learn that the app builds without a key
- **THEN** they SHALL learn where to put a local key for real Gemini recommendation calls
- **THEN** they SHALL learn that real keys must not be committed
