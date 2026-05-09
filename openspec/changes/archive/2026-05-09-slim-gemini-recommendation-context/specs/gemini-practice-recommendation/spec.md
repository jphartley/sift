## MODIFIED Requirements

### Requirement: System uses Gemini to recommend practices

The system SHALL use Google Gemini to analyze the user's voice check-in transcript and recommend 2–3 wellness practices from the curated library. The system SHALL construct a prompt containing the full current transcript, bounded selected prior session history, and a compact representation of the complete practice library. Each practice entry in the prompt SHALL include recommendation-selection metadata including id, name, category, duration, intensity, labels, summary, and best-fit situations. The system SHALL use `gemini-3-flash-preview` as the default model.

#### Scenario: Gemini returns recommendations successfully

- **WHEN** a transcript is available and Gemini responds with valid structured JSON
- **THEN** the system SHALL extract 2–3 practice IDs, an overarching rationale, per-practice relevance text, and a confidence score (0.0–1.0)
- **THEN** the system SHALL transition to the suggestion view displaying the recommended practices with their rationale and relevance text

#### Scenario: No prior sessions exist

- **WHEN** the user has no prior sessions in history
- **THEN** the system SHALL still send a valid prompt containing only the current transcript and compact complete practice library
- **THEN** the system SHALL return recommendations based solely on the current transcript

### Requirement: Gemini prompt includes bounded smart user history

The system SHALL include a bounded selected set of prior sessions in the Gemini prompt. The selected set SHALL include recent sessions plus older sessions with helpful practice attempts when available. Each included session SHALL include the full transcript text, the practice name attempted when present, and the helpfulness rating when present. The system SHALL NOT include unlimited prior sessions in a recommendation prompt.

#### Scenario: User has fewer sessions than the history limit

- **WHEN** the user has fewer prior sessions than the configured recommendation history limit
- **THEN** the system SHALL include those prior sessions in the Gemini prompt
- **THEN** each included session SHALL include its full transcript, practice name when present, and helpfulness rating when present

#### Scenario: User has more sessions than the history limit

- **WHEN** the user has more prior sessions than the configured recommendation history limit
- **THEN** the system SHALL include a bounded selected set of sessions rather than all prior sessions
- **THEN** the selected set SHALL include recent sessions
- **THEN** the selected set SHALL include older helpful practice attempts when available

#### Scenario: User has prior sessions with no practice attempted

- **WHEN** a selected prior session has no associated practice attempts
- **THEN** the system SHALL still include the session transcript in the prompt without practice or helpfulness data

### Requirement: Gemini prompt uses compact practice metadata

The system SHALL include compact metadata useful for recommendation matching while omitting full practice execution details from the Gemini prompt.

#### Scenario: Prompt includes compact matching metadata

- **WHEN** the system builds a Gemini recommendation prompt
- **THEN** each practice entry SHALL include id, name, category, duration, intensity, labels, summary, and best-fit situations
- **THEN** each practice entry SHALL omit full step lists, avoid-when guidance, keywords, and why-it-helps explanation
- **THEN** the prompt SHALL remain valid when the user has no prior history
