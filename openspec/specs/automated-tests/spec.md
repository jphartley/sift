## ADDED Requirements

### Requirement: PracticeLibrary keyword matching returns ranked results

The system SHALL have automated tests verifying that `Practice.match(transcript:)` correctly ranks practices by keyword match count.

#### Scenario: Empty transcript returns all practices with zero score
- **WHEN** the match function receives an empty string
- **THEN** all practices SHALL appear in the result array with a score of zero

#### Scenario: Single keyword matches one practice
- **WHEN** the transcript contains only the word "breath"
- **THEN** Box Breathing and 4-7-8 Breathing SHALL rank highest (both have "breath" as a keyword)

#### Scenario: Short words are ignored
- **WHEN** the transcript contains only words of 2 or fewer characters
- **THEN** all practices SHALL score zero

#### Scenario: Multiple keywords compound scoring
- **WHEN** the transcript contains "anxious stressed tense"
- **THEN** practices with more matching keywords SHALL rank higher than practices with fewer

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

### Requirement: Practice ranking boosts previously helpful practices

The system SHALL have automated tests verifying that practices previously marked helpful receive a ranking bonus.

#### Scenario: Previously helpful practice ranks above equal match
- **WHEN** a PracticeAttempt with wasHelpful true exists for Box Breathing
- **AND** the transcript matches Box Breathing and 4-7-8 Breathing equally
- **THEN** Box Breathing SHALL rank above 4-7-8 Breathing

#### Scenario: No helpful history gives no bonus
- **WHEN** no PracticeAttempts exist
- **THEN** practice ranking SHALL depend solely on keyword match count

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

#### Scenario: Empty placeholder fails before network
- **WHEN** automated tests exercise Gemini recommendation behavior with an empty key
- **THEN** the tests SHALL assert the missing-key error is returned
- **THEN** the tests SHALL assert no Gemini model request is made
