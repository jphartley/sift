## ADDED Requirements

### Requirement: Recommendation behavior is available through injectable client
The system SHALL expose Gemini practice recommendation behavior through an injectable recommendation client boundary used by the check-in flow.

#### Scenario: Production recommendation client uses Gemini
- **WHEN** the app runs in production
- **THEN** the recommendation client used by the check-in flow SHALL preserve the existing Gemini Flash-to-Pro routing behavior
- **THEN** it SHALL return the same recommendation result data needed by the suggestion view and session persistence

#### Scenario: Test recommendation client bypasses network
- **WHEN** automated tests run the check-in flow
- **THEN** tests SHALL be able to provide a recommendation client that returns deterministic recommendations without making Gemini network requests

### Requirement: Recommendation result validation remains compatible with practice resolution
The system SHALL ensure recommendation results provided to the check-in flow can be resolved against the local practice library before suggestions are displayed.

#### Scenario: Recommendation contains known practices
- **WHEN** the recommendation client returns practice IDs that exist in the practice library
- **THEN** the check-in flow SHALL display those practices with their relevance text

#### Scenario: Recommendation contains no resolvable practices
- **WHEN** the recommendation client returns no practice IDs that exist in the practice library
- **THEN** the check-in flow SHALL surface an error or empty state instead of presenting an empty suggestion list as a successful recommendation
