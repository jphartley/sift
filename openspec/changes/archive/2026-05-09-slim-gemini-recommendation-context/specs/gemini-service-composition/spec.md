## MODIFIED Requirements

### Requirement: Prompt construction is independently testable
The system SHALL provide a Gemini prompt builder that constructs the practice recommendation prompt from the current transcript, compact complete practice library representation, and bounded selected session history without requiring network-capable Gemini service initialization.

#### Scenario: Prompt builder receives current transcript
- **WHEN** the prompt builder receives a transcript and no history
- **THEN** the resulting prompt SHALL include the current check-in section
- **THEN** the resulting prompt SHALL include the transcript
- **THEN** the resulting prompt SHALL include the complete practice library using compact practice entries

#### Scenario: Prompt builder receives session history
- **WHEN** the prompt builder receives selected prior session history
- **THEN** the resulting prompt SHALL include the user history section
- **THEN** each included session SHALL include transcript, attempted practice name when present, and helpfulness rating when present

#### Scenario: Prompt builder receives rich practice records
- **WHEN** the prompt builder receives rich practice records from the local practice library
- **THEN** the resulting prompt SHALL use only the compact Gemini-facing fields for each practice
- **THEN** the resulting prompt SHALL NOT include practice steps, avoid-when guidance, keywords, or why-it-helps explanation
