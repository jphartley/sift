## Purpose
Define the automated test coverage expected for models, SwiftData behavior, view models, Gemini collaborators, async task lifecycle, and local secret fallback behavior.
## Requirements
### Requirement: Practice library data is valid

The system SHALL have automated tests verifying the integrity of the curated practice library.

#### Scenario: All practices have unique IDs
- **WHEN** the practice library is loaded
- **THEN** no two practices SHALL share the same id

#### Scenario: All practices have non-empty keywords
- **WHEN** the practice library is loaded
- **THEN** every practice SHALL have at least one keyword

#### Scenario: All practices have positive duration
- **WHEN** the practice library is loaded
- **THEN** every practice SHALL have durationMinutes greater than zero

### Requirement: Session model initializes correctly

The system SHALL have automated tests verifying Session model defaults.

#### Scenario: Default initializer sets empty attempts
- **WHEN** a Session is initialized with default parameters
- **THEN** attempts SHALL be an empty array

#### Scenario: Custom initializer preserves values
- **WHEN** a Session is initialized with specific transcript and duration
- **THEN** transcript and audioDuration SHALL match the provided values

### Requirement: PracticeAttempt model initializes correctly

The system SHALL have automated tests verifying PracticeAttempt model defaults.

#### Scenario: Default initializer sets completed to true
- **WHEN** a PracticeAttempt is initialized with default parameters
- **THEN** completed SHALL be true and wasHelpful SHALL be nil

#### Scenario: Custom wasHelpful and notes are preserved
- **WHEN** a PracticeAttempt is initialized with wasHelpful true and notes "felt calm after"
- **THEN** wasHelpful SHALL be true and notes SHALL be "felt calm after"

### Requirement: RecordingState enum cases are distinct

The system SHALL have automated tests verifying RecordingState enum equality.

#### Scenario: Same state cases are equal
- **WHEN** two RecordingState values are .ready
- **THEN** they SHALL be equal

#### Scenario: Different state cases are not equal
- **WHEN** one value is .ready and another is .recording
- **THEN** they SHALL NOT be equal

#### Scenario: Associated values affect equality
- **WHEN** two .suggesting states have different transcripts
- **THEN** they SHALL NOT be equal

### Requirement: TranscriptionError provides descriptive messages

The system SHALL have automated tests verifying TranscriptionError localized descriptions.

#### Scenario: Model not loaded error message
- **WHEN** TranscriptionError.modelNotLoaded is queried for errorDescription
- **THEN** it SHALL return a non-empty string

#### Scenario: File not found error message
- **WHEN** TranscriptionError.fileNotFound is queried for errorDescription
- **THEN** it SHALL return a non-empty string

### Requirement: RecordingViewModel transitions through states correctly

The system SHALL have automated tests verifying the ViewModel state machine using in-memory SwiftData.

#### Scenario: logPractice creates attempt and transitions to reflecting
- **WHEN** a pending Session exists and logPractice is called with a practice ID and name
- **THEN** the state SHALL be .reflecting with the practice name
- **THEN** the Session's attempts array SHALL contain one PracticeAttempt

#### Scenario: completeReflection persists session and resets state
- **WHEN** a pending Session exists, an attempt has been logged, and completeReflection is called with wasHelpful true
- **THEN** the state SHALL transition to .ready
- **THEN** the Session SHALL be persisted to the in-memory context
- **THEN** the PracticeAttempt's wasHelpful SHALL be true

#### Scenario: skipSuggestions persists empty session
- **WHEN** a pending Session exists with no attempts and skipSuggestions is called
- **THEN** the state SHALL transition to .ready
- **THEN** the Session SHALL be persisted with an empty attempts array

#### Scenario: dismissPractice returns to suggesting
- **WHEN** a pending Session exists with one attempt logged and dismissPractice is called
- **THEN** the state SHALL transition to .suggesting
- **THEN** the Session's attempts SHALL be cleared

### Requirement: SwiftData relationship cascade deletes attempts

The system SHALL have automated tests verifying that deleting a Session cascades to its PracticeAttempts.

#### Scenario: Deleting session removes its attempts
- **WHEN** a Session with two PracticeAttempts is inserted and then deleted
- **THEN** fetching all PracticeAttempts SHALL return an empty array

### Requirement: FetchDescriptor predicate filters correctly

The system SHALL have automated tests verifying SwiftData predicate queries.

#### Scenario: wasHelpful predicate returns only helpful attempts
- **WHEN** one PracticeAttempt has wasHelpful true and another has wasHelpful false
- **THEN** fetching with predicate wasHelpful == true SHALL return exactly one result

### Requirement: RecordingViewModel tests exercise real flow methods
The system SHALL have automated tests that call real `RecordingViewModel` methods with fake service implementations instead of manually reproducing persistence or state changes.

#### Scenario: completeReflection test calls completeReflection
- **WHEN** a test verifies reflection completion
- **THEN** the test SHALL call `completeReflection`
- **THEN** the test SHALL assert saved session data through the fake or in-memory session store

#### Scenario: skipSuggestions test calls skipSuggestions
- **WHEN** a test verifies skipped suggestions
- **THEN** the test SHALL call `skipSuggestions`
- **THEN** the test SHALL assert that a session without attempts was saved

#### Scenario: stopRecording test drives transcription and recommendation
- **WHEN** a test verifies the successful stop-recording flow
- **THEN** the test SHALL use fake transcription and recommendation clients
- **THEN** the test SHALL assert the resulting `.suggesting` state and pending session metadata

### Requirement: Tests cover dependency failure paths
The system SHALL have automated tests for service and persistence failures that are practical to trigger with protocol-backed fakes.

#### Scenario: Recommendation fake throws
- **WHEN** the recommendation fake throws during analysis
- **THEN** the test SHALL assert the view model enters an error state while retaining the pending transcript for retry

#### Scenario: Session store fake throws on save
- **WHEN** the session store fake throws while saving reflection or skipped suggestions
- **THEN** the test SHALL assert the view model enters an error state
- **THEN** the test SHALL assert the session was not reported as successfully saved

#### Scenario: History fake is passed to recommender
- **WHEN** the session store fake returns prior history
- **THEN** the test SHALL assert the recommendation fake receives that history

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

### Requirement: Tests cover history deletion persistence behavior
The system SHALL have automated tests for history deletion success and failure paths using a testable persistence boundary or history state owner.

#### Scenario: History deletion calls persistence boundary
- **WHEN** a test deletes a session from history
- **THEN** the test SHALL assert the selected session is passed to the persistence boundary for deletion

#### Scenario: History deletion failure is surfaced
- **WHEN** the persistence boundary throws while deleting a session from history
- **THEN** the test SHALL assert the history flow records a user-visible error state

#### Scenario: SwiftData cascade deletion remains covered
- **WHEN** a Session with PracticeAttempts is deleted through the real SwiftData-backed store or existing in-memory SwiftData coverage
- **THEN** the test SHALL assert associated PracticeAttempts are removed

### Requirement: Existing Gemini service tests remain behavior-focused
The system SHALL keep `GeminiService` tests focused on facade-level recommendation behavior and error mapping after lower-level prompt, parser, and routing tests are introduced.

#### Scenario: GeminiService facade is tested
- **WHEN** automated tests instantiate `GeminiService`
- **THEN** the tests SHALL verify externally observable recommendation-client behavior
- **THEN** collaborator-specific details SHALL be verified in collaborator tests instead of through broad service tests

### Requirement: Tests cover check-in async task lifecycle
The system SHALL have automated tests verifying that the voice check-in flow cancels and replaces owned async tasks.

#### Scenario: Meter polling is canceled on stop
- **WHEN** a test starts recording and then stops recording
- **THEN** the test SHALL assert that recording meter polling no longer updates view model meter state after stop

#### Scenario: Retry analysis cancels previous analysis
- **WHEN** a test starts retry analysis while an earlier analysis task is still in flight
- **THEN** the test SHALL assert that the earlier analysis result cannot replace the newer analysis result

#### Scenario: Teardown cancels in-flight analysis
- **WHEN** a test calls the recording view model teardown hook while analysis is in flight
- **THEN** the test SHALL assert that the canceled analysis does not transition to suggestions or an analysis error caused only by cancellation

#### Scenario: Teardown stops active recording
- **WHEN** a test calls the recording view model teardown hook while recording is active
- **THEN** the test SHALL assert that the audio recorder is stopped
- **THEN** the test SHALL assert that meter polling is canceled

### Requirement: Tests cover safe secret fallback behavior
The system SHALL have automated coverage proving Gemini API key setup remains safe and explicit.

#### Scenario: Placeholder key is accessible
- **WHEN** automated tests access `Secrets.geminiApiKey`
- **THEN** the value SHALL be available as a `String` without requiring a private local secret file

#### Scenario: Bundled local key is read
- **WHEN** automated tests provide a bundle containing `GeminiAPIKey.local`
- **THEN** the tests SHALL assert `Secrets.geminiApiKey` reads the bundled key value

#### Scenario: Empty placeholder fails before network
- **WHEN** automated tests exercise Gemini recommendation behavior with an empty key
- **THEN** the tests SHALL assert the missing-key error is returned
- **THEN** the tests SHALL assert no Gemini model request is made

### Requirement: Tests cover ready-screen orientation

The system SHALL have automated tests verifying that the ready recording screen exposes the first-screen orientation expected for internal beta readiness.

#### Scenario: Orientation copy is test-covered
- **WHEN** automated tests exercise the ready recording screen or its view-adjacent presentation data
- **THEN** the tests SHALL verify that the orientation includes the heading "Take a moment to arrive"
- **THEN** the tests SHALL verify that the orientation includes "There is no right or wrong way to do this"
- **THEN** the tests SHALL verify that the orientation includes "what feels most alive right now"
- **THEN** the tests SHALL verify that the starter prompts are exposed

#### Scenario: Existing voice check-in behavior remains covered
- **WHEN** automated tests run after the orientation change
- **THEN** existing tests for recording setup, recording start, transcription, recommendation, persistence, and cancellation SHALL continue to pass

#### Scenario: Returning guidance is test-covered
- **WHEN** automated tests exercise the ready recording screen presentation data
- **THEN** the tests SHALL verify that the returning heading is "Check in again"
- **THEN** the tests SHALL verify that the returning guidance includes "Record another short voice note", "what feels most alive right now", and "A minute is enough"
- **THEN** the tests SHALL verify that first-time starter prompts remain separate from returning guidance

### Requirement: Tests cover Privacy tab and trust copy

The system SHALL have automated tests verifying that the Privacy tab exists and exposes the core privacy/trust copy.

#### Scenario: Privacy tab is covered
- **WHEN** automated UI or view-adjacent tests exercise the main tab interface
- **THEN** the tests SHALL verify that a "Privacy" tab is available

#### Scenario: Privacy copy is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that audio-on-phone handling is represented
- **THEN** the tests SHALL verify that transcript-to-Gemini handling is represented
- **THEN** the tests SHALL verify that local history and deletion are represented
- **THEN** the tests SHALL verify that developer access limits are represented
- **THEN** the tests SHALL verify that Jeremy Hartley and `jphartley@gmail.com` are represented

#### Scenario: AI suggestion disclosure is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that Sift does not attach the user's name, email, or account to Gemini requests
- **THEN** the tests SHALL verify that spoken identifying details remain part of the transcript sent to Gemini
- **THEN** the tests SHALL verify that paid Gemini API data-use language is represented

### Requirement: Tests cover sensitive logging guardrails

The system SHALL have automated tests or static checks verifying that the recommendation flow does not log sensitive check-in content.

#### Scenario: Gemini logging avoids raw response text
- **WHEN** automated tests or static checks inspect Gemini request error handling
- **THEN** they SHALL verify that raw Gemini response text is not printed to the developer console

#### Scenario: Gemini logging remains metadata-only
- **WHEN** automated tests or static checks inspect Gemini recommendation logging
- **THEN** they SHALL allow non-sensitive metadata such as model names, prompt length, history count, confidence, escalation state, and practice IDs
- **THEN** they SHALL reject logging of transcript text, full prompt text, or raw response text

### Requirement: Tests cover emotional safety guidance

The system SHALL have automated tests verifying that beta emotional-safety guidance is visible, plain-language, and soft in tone.

#### Scenario: Privacy safety copy is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that the Safety section states Sift is for reflection and practice suggestions
- **THEN** the tests SHALL verify that the Safety section states Sift is not a therapist, doctor, or crisis service
- **THEN** the tests SHALL verify that the Safety section gives users permission to pause, skip, adapt, or stop a practice
- **THEN** the tests SHALL verify that the Safety section mentions reaching out to someone they trust

#### Scenario: Urgent support copy is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that the Safety section covers risk of hurting yourself or someone else
- **THEN** the tests SHALL verify that the Safety section covers not feeling safe
- **THEN** the tests SHALL verify that the Safety section mentions emergency support or a trusted person

### Requirement: Tests cover practice safety-note agency language

The system SHALL have automated tests verifying that contextual practice safety notes preserve user agency.

#### Scenario: High-intensity practice note is covered
- **WHEN** automated tests exercise practice detail presentation for a high-intensity practice
- **THEN** the tests SHALL verify that the safety note tells users to go slowly
- **THEN** the tests SHALL verify that the safety note says users can adapt or stop

#### Scenario: Avoid-when practice note is covered
- **WHEN** automated tests exercise practice detail presentation for a practice with avoid-when guidance
- **THEN** the tests SHALL verify that the safety note contains the avoid-when guidance
- **THEN** the tests SHALL verify that the safety note says users can adapt or stop

### Requirement: Tests cover calm recovery presentation

The system SHALL have automated tests verifying that recoverable check-in failures map to calm, action-specific recovery presentation.

#### Scenario: Microphone Settings action is covered
- **WHEN** automated tests exercise microphone permission denial
- **THEN** the tests SHALL verify that the recovery presentation explains microphone access is needed
- **THEN** the tests SHALL verify that an "Open Settings" action is available
- **THEN** the tests SHALL verify that the Settings action targets the app's system Settings page

#### Scenario: Model loading recovery is covered
- **WHEN** automated tests exercise model loading failure presentation
- **THEN** the tests SHALL verify that the recovery presentation explains Sift could not prepare speech recognition
- **THEN** the tests SHALL verify that the presentation includes a retry action
- **THEN** the tests SHALL verify that the presentation reassures the user that nothing was lost

#### Scenario: Empty speech recovery is covered
- **WHEN** automated tests exercise empty or whitespace-only transcription output
- **THEN** the tests SHALL verify that the flow does not continue into recommendation analysis
- **THEN** the tests SHALL verify that the recovery presentation says the check-in did not come through
- **THEN** the tests SHALL verify that the presentation offers recording again

#### Scenario: Analysis failure recovery is covered
- **WHEN** automated tests exercise recommendation analysis failure after transcription
- **THEN** the tests SHALL verify that the pending transcript remains available
- **THEN** the tests SHALL verify that the recovery presentation says suggestions did not load
- **THEN** the tests SHALL verify that retrying suggestions reuses the existing transcript

#### Scenario: Empty suggestion recovery is covered
- **WHEN** automated tests exercise an analysis result with no usable practices
- **THEN** the tests SHALL verify that the recovery presentation avoids blaming the user
- **THEN** the tests SHALL verify that a retry suggestions action is available

### Requirement: Tests cover suggestion explainability copy

The system SHALL have automated tests verifying that the suggestion experience exposes rationale and relevance in human-facing coaching language while hiding model-routing implementation details.

#### Scenario: Rationale label is covered
- **WHEN** automated tests exercise suggestion view presentation data or the suggestion view
- **THEN** the tests SHALL verify that the rationale label is "Why these might fit"
- **THEN** the tests SHALL verify that the old label "Analysis" is not used for the suggestion rationale

#### Scenario: Relevance label is covered
- **WHEN** automated tests exercise expanded practice card presentation data or the expanded practice card
- **THEN** the tests SHALL verify that relevance text is associated with the label "Why this might help"
- **THEN** the tests SHALL verify that relevance text remains available when a practice has relevance copy

#### Scenario: Model-routing details are hidden from beta-facing suggestion UI
- **WHEN** automated tests exercise suggestion presentation for an escalated recommendation result
- **THEN** the tests SHALL verify that the main suggestion UI copy does not include "Escalated to Pro model"

### Requirement: Tests cover first-time setup presentation

The system SHALL have automated tests verifying that the model-loading setup experience is clear, reassuring, and phase-specific.

#### Scenario: Setup copy is covered
- **WHEN** automated tests exercise first-time setup presentation data
- **THEN** the tests SHALL verify that setup copy explains Sift is preparing on-device speech recognition
- **THEN** the tests SHALL verify that setup copy says first setup can take a little while
- **THEN** the tests SHALL verify that setup copy avoids prototype terms such as "speech model"

#### Scenario: Download phase presentation is covered
- **WHEN** automated tests exercise setup presentation for model downloading
- **THEN** the tests SHALL verify that determinate progress is represented
- **THEN** the tests SHALL verify that the status copy describes getting speech recognition ready

#### Scenario: Local preparation phase presentation is covered
- **WHEN** automated tests exercise setup presentation for local model preparation
- **THEN** the tests SHALL verify that an active loading state is represented
- **THEN** the tests SHALL verify that the status copy describes preparing speech recognition on device

#### Scenario: Existing ready orientation remains covered
- **WHEN** automated tests run after setup presentation changes
- **THEN** existing ready-screen orientation tests SHALL continue to verify the ready check-in screen copy

### Requirement: Tests cover responsive microphone startup

The system SHALL have automated tests verifying that the first microphone tap is acknowledged immediately and cannot trigger overlapping startup work.

#### Scenario: Preparing-to-record state is covered
- **WHEN** automated tests call recording start from the ready state with permission still pending
- **THEN** the tests SHALL verify that the view model enters a preparing-to-record state before recording begins
- **THEN** the tests SHALL verify that the UI copy for this state includes "Getting microphone ready"

#### Scenario: Duplicate start taps are ignored
- **WHEN** automated tests call recording start more than once while startup is pending
- **THEN** the tests SHALL verify that only one recorder startup request is made
- **THEN** the tests SHALL verify that recording still starts once permission and recorder setup succeed

#### Scenario: Permission denial recovery remains covered
- **WHEN** automated tests exercise microphone permission denial during startup
- **THEN** the tests SHALL verify that the preparing-to-record state exits
- **THEN** the tests SHALL verify that the microphone recovery state remains available

### Requirement: Tests cover startup storage preparation

The system SHALL have automated tests or static checks verifying that startup prepares the local storage parent directory before SwiftData initialization.

#### Scenario: Application Support directory preparation is covered
- **WHEN** automated tests or static checks inspect app startup behavior
- **THEN** they SHALL verify that the Application Support directory is created before `ModelContainer` initialization
- **THEN** they SHALL verify that the default SwiftData store location and schema are not changed
- **THEN** the tests SHALL verify that the main suggestion UI copy avoids provider names, model names, confidence scores, routing terms, and debug language

#### Scenario: Internal routing behavior remains covered separately
- **WHEN** automated tests exercise Gemini routing and RecordingViewModel recommendation state
- **THEN** existing tests SHALL continue to verify Flash-to-Pro escalation behavior and internal escalation state without depending on a user-facing escalation toast

### Requirement: Tests cover TestFlight-facing app metadata

The system SHALL have automated coverage or static project checks for app metadata that external TestFlight testers and reviewers see.

#### Scenario: Display name metadata is covered
- **WHEN** automated tests or static checks inspect app target metadata
- **THEN** they SHALL verify that the app display name is "Sift"

#### Scenario: Microphone usage description metadata is covered
- **WHEN** automated tests or static checks inspect app target metadata
- **THEN** they SHALL verify that the microphone usage description mentions voice check-ins
- **THEN** they SHALL verify that the microphone usage description mentions on-device transcription
- **THEN** they SHALL verify that the microphone usage description does not contain prototype wording such as voice samples or speech-to-text evaluation

#### Scenario: Version metadata is covered
- **WHEN** automated tests or static checks inspect app target metadata
- **THEN** they SHALL verify that the app target has explicit marketing version and current project version values
