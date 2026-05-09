## Purpose
Define how Gemini analyzes check-in transcripts, routes between models, handles API keys and failures, and returns practice recommendations.
## Requirements
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

### Requirement: System routes between Flash and Pro models based on confidence and server health

The system SHALL use `gemini-3-flash-preview` for every initial recommendation request. The system SHALL escalate to `gemini-3.1-pro-preview` when the Flash response returns a confidence score below 0.7. The system SHALL also silently fall back to Pro when Flash fails with a transient server error (HTTP 429, 500, 502, 503, 504, or "unavailable" status). Model-routing details SHALL remain internal and SHALL NOT be shown in the main suggestion UI.

#### Scenario: Flash returns high confidence

- **WHEN** `gemini-3-flash-preview` returns recommendations with confidence >= 0.7
- **THEN** the system SHALL use that response and SHALL NOT escalate to Pro

#### Scenario: Flash returns low confidence

- **WHEN** `gemini-3-flash-preview` returns recommendations with confidence < 0.7
- **THEN** the system SHALL retry the request with `gemini-3.1-pro-preview`
- **THEN** the system SHALL use the Pro response regardless of its confidence
- **THEN** the system SHALL preserve metadata that Pro escalation occurred for internal routing, persistence, debugging, or developer diagnostics
- **THEN** the system SHALL NOT show Pro escalation in the main suggestion UI

#### Scenario: Flash fails with transient server error

- **WHEN** `gemini-3-flash-preview` fails with an HTTP 429, 500, 502, 503, 504, or "unavailable" status
- **THEN** the system SHALL automatically retry the request with `gemini-3.1-pro-preview` without showing an error to the user
- **THEN** the system SHALL log the fallback to the console
- **THEN** the system SHALL preserve metadata that Pro escalation occurred for internal routing, persistence, debugging, or developer diagnostics
- **THEN** the system SHALL NOT show Pro escalation in the main suggestion UI

#### Scenario: Both Flash and Pro fail

- **WHEN** both `gemini-3-flash-preview` and `gemini-3.1-pro-preview` fail
- **THEN** the system SHALL display an error message with a retry button

### Requirement: System persists Gemini recommendation data

The system SHALL persist the Gemini rationale, model used, and confidence score with the associated Session in SwiftData.

#### Scenario: Session completed with Gemini recommendations

- **WHEN** the user completes a session (selects a practice or skips suggestions)
- **THEN** the system SHALL persist `geminiRationale`, `geminiModelUsed`, and `geminiConfidence` as part of the Session record
- **THEN** the system SHALL persist nil for all three fields if Gemini was never invoked (e.g., transcription failed)

### Requirement: System displays Gemini rationale and relevance

The system SHALL display the recommendation rationale and per-practice relevance text in human-facing coaching language. The main suggestion UI SHALL NOT label these explanations as Gemini output, model output, confidence data, routing data, or debug information.

#### Scenario: Gemini recommendations include rationale

- **WHEN** Gemini returns an overarching rationale string
- **THEN** the system SHALL display the rationale prominently in the suggestion view before the practice cards
- **THEN** the rationale SHALL be presented with a coaching-flavored label such as "Why these might fit"
- **THEN** the rationale presentation SHALL avoid provider names, model names, confidence scores, routing terms, and debug language

#### Scenario: Gemini recommendations include per-practice relevance

- **WHEN** Gemini returns a relevance string for a given practice
- **THEN** the system SHALL display that relevance text on or below the corresponding practice card when the card is expanded
- **THEN** the relevance presentation SHALL avoid provider names, model names, confidence scores, routing terms, and debug language

### Requirement: System handles Gemini failures gracefully

The system SHALL detect Gemini API errors after both Flash and Pro have been attempted. The system SHALL display an inline error state with a retry button that re-initiates the full Flash → Pro flow.

#### Scenario: Both models return an error

- **WHEN** both Flash and Pro attempts fail (after transient fallback has been exhausted)
- **THEN** the system SHALL display an error message describing the failure
- **THEN** the system SHALL display a retry button

#### Scenario: User retries after Gemini failure

- **WHEN** the user taps the retry button
- **THEN** the system SHALL re-send the recommendation request to `gemini-3-flash-preview`
- **THEN** the system SHALL follow the same Flash → Pro escalation path as the initial request

#### Scenario: Gemini returns invalid JSON

- **WHEN** Gemini returns a response that cannot be parsed into the expected structured output schema
- **THEN** the system SHALL treat this as a failure and display the error state with retry button

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

### Requirement: Gemini service is instantiated and injected at app launch

The system SHALL create a single Gemini service instance at app launch following the same pattern as TranscriptionService. The service SHALL be injected into the SwiftUI environment and consumed by RecordingViewModel.

#### Scenario: App launches successfully

- **WHEN** the app launches
- **THEN** the system SHALL instantiate GeminiService without making any network requests
- **THEN** the system SHALL not validate the API key at launch time

### Requirement: API key is stored in a gitignored source file

The system SHALL read the Gemini API key from `Secrets.geminiApiKey`. The repository SHALL provide a checked-in, debug-safe default value so the app compiles from a fresh clone without a private key. Real Gemini API keys SHALL remain excluded from version control. A committed template or first-run setup instructions SHALL explain how to configure a local key for real Gemini requests. Local builds SHALL copy the ignored key file into the app bundle when it exists so simulator and device runtime behavior match.

#### Scenario: Fresh clone builds without local key

- **WHEN** the repository is cloned without a private local secret file
- **THEN** the app SHALL still compile with a safe placeholder `Secrets.geminiApiKey` value

#### Scenario: API key is configured

- **WHEN** the developer configures a non-empty local `geminiApiKey` value
- **THEN** the system SHALL use it for Gemini API requests
- **THEN** the system SHALL support both simulator and device builds

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

### Requirement: Gemini recommendation behavior remains compatible after internal split
The system SHALL preserve the existing Gemini practice recommendation behavior when `GeminiService` is refactored into focused internal collaborators.

#### Scenario: Gemini returns recommendations successfully
- **WHEN** Gemini responds with valid structured JSON after the internal split
- **THEN** the system SHALL extract 2-3 practice IDs, an overarching rationale, per-practice relevance text, and a confidence score
- **THEN** the system SHALL return recommendation result data compatible with the suggestion view and session persistence

#### Scenario: Flash routes to Pro after low confidence
- **WHEN** the Flash response returns confidence below 0.7 after the internal split
- **THEN** the system SHALL retry the request with `gemini-3.1-pro-preview`
- **THEN** the system SHALL use the Pro response regardless of its confidence

#### Scenario: Gemini returns invalid JSON after internal split
- **WHEN** Gemini returns a response that cannot be parsed into the expected structured output schema after the internal split
- **THEN** the system SHALL treat this as a failure compatible with the existing Gemini error flow

#### Scenario: API key is missing after internal split
- **WHEN** `Secrets.geminiApiKey` is empty
- **THEN** the first Gemini recommendation request SHALL fail with the existing missing API key error

### Requirement: Gemini prompt uses compact practice metadata

The system SHALL include compact metadata useful for recommendation matching while omitting full practice execution details from the Gemini prompt.

#### Scenario: Prompt includes compact matching metadata

- **WHEN** the system builds a Gemini recommendation prompt
- **THEN** each practice entry SHALL include id, name, category, duration, intensity, labels, summary, and best-fit situations
- **THEN** each practice entry SHALL omit full step lists, avoid-when guidance, keywords, and why-it-helps explanation
- **THEN** the prompt SHALL remain valid when the user has no prior history

