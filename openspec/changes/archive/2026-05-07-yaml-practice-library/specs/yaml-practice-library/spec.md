## ADDED Requirements

### Requirement: System loads practices from YAML resource file

The system SHALL load wellness practice definitions from a bundled YAML resource file (`practices.yaml`) at app launch. Each practice SHALL have an id, name, category, keywords, description, and duration in minutes.

#### Scenario: YAML file loads successfully

- **WHEN** the app launches and the YAML file is present in the bundle
- **THEN** the system SHALL decode all practices into Practice structs
- **THEN** the decoded practices SHALL be accessible for Gemini prompt construction and practice display

#### Scenario: YAML file is missing from bundle

- **WHEN** the app launches and `practices.yaml` is not found in the bundle
- **THEN** the system SHALL enter an error state indicating the practice library could not be loaded
- **THEN** the app SHALL display an error message to the user

#### Scenario: YAML file contains malformed data

- **WHEN** the app launches and `practices.yaml` contains invalid YAML that cannot be decoded
- **THEN** the system SHALL enter an error state with a descriptive message
- **THEN** the app SHALL display an error message to the user

### Requirement: Practice struct supports YAML decoding

The Practice struct SHALL conform to Decodable with CodingKeys mapping snake_case YAML keys (e.g., `duration_minutes`) to camelCase Swift properties (e.g., `durationMinutes`).

#### Scenario: Practice decodes from valid YAML

- **WHEN** a YAML representation of a practice contains id, name, category, keywords, description, and duration_minutes
- **THEN** the system SHALL successfully decode it into a Practice struct with all fields populated

#### Scenario: YAML contains extra unknown keys

- **WHEN** a YAML representation includes a key not defined in the Practice struct's CodingKeys
- **THEN** the system SHALL ignore the unknown key and decode the practice without error

### Requirement: Practice library is validated at test time

The system SHALL include a unit test that loads the bundled `practices.yaml` and asserts it decodes without errors and contains at least the expected number of practices.

#### Scenario: Bundled YAML passes validation

- **WHEN** the validation test runs
- **THEN** the system SHALL decode the YAML file without throwing an error
- **THEN** the system SHALL assert the decoded practice list is non-empty

#### Scenario: Test catches malformed YAML

- **WHEN** a developer introduces a syntax error in `practices.yaml`
- **THEN** the validation test SHALL fail with a decoding error

## MODIFIED Requirements

### Requirement: System maintains a curated practice library

The system SHALL include a curated library of wellness practices loaded from a bundled YAML resource file. Each practice SHALL have an identifier, name, category, keywords, a description, and an estimated duration.

#### Scenario: Practice data is available
- **WHEN** the app loads
- **THEN** all practices in the YAML library SHALL be accessible for Gemini prompt construction and practice display
