## MODIFIED Requirements

### Requirement: System maintains a curated practice library

The system SHALL include a curated library of wellness practices loaded from a bundled YAML resource file. Each practice SHALL have an identifier, name, category, keywords, a description, and an estimated duration.

#### Scenario: Practice data is available
- **WHEN** the app loads
- **THEN** all practices in the YAML library SHALL be accessible for Gemini prompt construction and practice display
