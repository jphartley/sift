## MODIFIED Requirements

### Requirement: System uses Gemini to recommend practices

The system SHALL use Google Gemini to analyze the user's voice check-in transcript and recommend 2–3 wellness practices from the curated library. The system SHALL construct a prompt containing the full transcript, all prior session history with practice attempts, and the complete practice library. Each practice entry in the prompt SHALL include richer recommendation metadata including id, name, category, duration, intensity, labels, summary, best-fit situations, and why-it-helps explanation. The system SHALL use `gemini-3-flash-preview` as the default model.

#### Scenario: Gemini returns recommendations successfully

- **WHEN** a transcript is available and Gemini responds with valid structured JSON
- **THEN** the system SHALL extract 2–3 practice IDs, an overarching rationale, per-practice relevance text, and a confidence score (0.0–1.0)
- **THEN** the system SHALL transition to the suggestion view displaying the recommended practices with their rationale and relevance text

#### Scenario: No prior sessions exist

- **WHEN** the user has no prior sessions in history
- **THEN** the system SHALL still send a valid prompt containing only the current transcript and practice library
- **THEN** the system SHALL return recommendations based solely on the current transcript

## ADDED Requirements

### Requirement: Gemini prompt uses enriched practice metadata without guided steps

The system SHALL include enriched metadata useful for recommendation matching while omitting full practice step lists from the Gemini prompt.

#### Scenario: Prompt includes matching metadata

- **WHEN** the system builds a Gemini recommendation prompt
- **THEN** each practice entry SHALL include the practice summary, labels, best-fit situations, why-it-helps explanation, duration, category, and intensity
- **THEN** the prompt SHALL remain valid when the user has no prior history
