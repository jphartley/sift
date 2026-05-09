## Purpose
Define how `GeminiService` remains the production recommendation facade while delegating prompt construction, parsing, and routing to focused collaborators.

## Requirements

### Requirement: Gemini recommendation client composes focused collaborators
The system SHALL keep `GeminiService` as the production recommendation client facade while delegating prompt construction, response parsing, and model-routing decisions to focused internal collaborators.

#### Scenario: Check-in flow requests recommendations
- **WHEN** the check-in flow asks the production recommendation client for practices
- **THEN** `GeminiService` SHALL remain the object satisfying the `RecommendationClient` boundary
- **THEN** the check-in flow SHALL NOT depend directly on Gemini prompt, parser, or routing collaborators

#### Scenario: GeminiService builds a recommendation request
- **WHEN** `GeminiService` prepares a Gemini recommendation request
- **THEN** prompt construction SHALL be performed by a dedicated prompt builder collaborator
- **THEN** response decoding and validation SHALL be performed by a dedicated parser collaborator

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

### Requirement: Gemini response parsing is independently testable
The system SHALL provide a Gemini recommendation parser that converts structured Gemini JSON text into `RecommendationResult` data and validates the required response shape before recommendations are displayed.

#### Scenario: Parser receives valid recommendation JSON
- **WHEN** the parser receives JSON containing rationale, confidence, and one or more practice entries with practice IDs and relevance text
- **THEN** it SHALL return recommendation result data containing the parsed rationale, confidence, and practices

#### Scenario: Parser receives malformed JSON
- **WHEN** the parser receives text that is not valid JSON
- **THEN** it SHALL fail with the existing Gemini parse error behavior

#### Scenario: Parser receives no practice recommendations
- **WHEN** the parser receives valid JSON with no parseable practice entries
- **THEN** it SHALL fail with the existing empty-practices behavior

### Requirement: Flash and Pro routing is testable without network
The system SHALL isolate Gemini model request behavior so Flash/Pro routing decisions can be verified using deterministic test doubles instead of live Gemini network calls.

#### Scenario: Flash response has high confidence
- **WHEN** the Flash model request returns recommendations with confidence greater than or equal to the configured threshold
- **THEN** routing SHALL return the Flash result
- **THEN** routing SHALL NOT request the Pro model

#### Scenario: Flash response has low confidence
- **WHEN** the Flash model request returns recommendations with confidence below the configured threshold
- **THEN** routing SHALL request the Pro model
- **THEN** routing SHALL return the Pro result marked as escalated

#### Scenario: Flash request fails with retryable server error
- **WHEN** the Flash model request fails with a retryable server error
- **THEN** routing SHALL request the Pro model
- **THEN** routing SHALL return the Pro result marked as escalated

#### Scenario: Flash request fails with non-retryable error
- **WHEN** the Flash model request fails with a non-retryable error
- **THEN** routing SHALL surface that failure
- **THEN** routing SHALL NOT request the Pro model
