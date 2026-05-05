## 1. Project Setup

- [x] 1.1 Add `google-generative-ai-swift` SPM dependency to Xcode project (latest stable version)
- [x] 1.2 Create `Secrets.xcconfig.example` with placeholder `GEMINI_API_KEY = YOUR_KEY_HERE`
- [x] 1.3 Create `Secrets.xcconfig` (actual file stays local, gitignored)
- [x] 1.4 Configure project to use `Secrets.xcconfig` in Debug and Release build configurations
- [x] 1.5 Add `GEMINI_API_KEY` entry to `Info.plist` referencing `$(GEMINI_API_KEY)`
- [x] 1.6 Add `Secrets.xcconfig` to `.gitignore`
- [x] 1.7 Build and verify the SPM dependency resolves correctly

## 2. GeminiService Implementation

- [x] 2.1 Create `sift/Services/GeminiService.swift` as `@Observable final class`
- [x] 2.2 Implement API key loading from `Bundle.main.object(forInfoDictionaryKey:)`
- [x] 2.3 Implement prompt construction: system instruction + practice library serialization (name, description, category, duration) + current transcript + full session history
- [x] 2.4 Implement `recommend(transcript:sessions:)` method returning structured recommendation result (rationale, practices with relevance, confidence, model used)
- [x] 2.5 Implement Flash → Pro routing: send to Flash, check confidence, escalate to Pro if < 0.7
- [x] 2.6 Implement JSON response parsing with `Decodable` types matching the expected schema
- [x] 2.7 Implement error handling: network errors, HTTP errors, JSON parse failures mapped to a `GeminiError` enum
- [x] 2.8 Add developer-visible escalation flag to the result type (for UI notification)

## 3. Session Model Changes

- [x] 3.1 Add `geminiRationale: String?` property to `Session`
- [x] 3.2 Add `geminiModelUsed: String?` property to `Session`
- [x] 3.3 Add `geminiConfidence: Double?` property to `Session`
- [x] 3.4 Run the build to verify SwiftData migration (auto-migration handles nullable additions)

## 4. RecordingState and ViewModel

- [x] 4.1 Add `.analyzing` case to `RecordingState` enum
- [x] 4.2 Update `RecordingViewModel` to inject `GeminiService` via `configure()`
- [x] 4.3 Replace `suggestPractices(for:)` implementation: call `GeminiService.recommend()` instead of `Practice.match()`
- [x] 4.4 Store Gemini result (rationale, model used, confidence) on `pendingSession` before transitioning to `.suggesting`
- [x] 4.5 Remove unused `rankPractices()` and `previouslyHelpfulIDs()` methods (no longer needed)
- [x] 4.6 Build the full session history payload from SwiftData for the Gemini prompt

## 5. UI Changes

- [x] 5.1 Add GeminiService instantiation and environment injection in `siftApp.swift`
- [x] 5.2 Add `analyzingView` with spinner and "Analyzing..." text in `RecordingScreen`
- [x] 5.3 Add `.analyzing` case to the state switch in `RecordingScreen`
- [x] 5.4 Add error-with-retry state: display error message and retry button for Gemini failures
- [x] 5.5 Update `SuggestionView` to accept and display `geminiRationale: String` parameter
- [x] 5.6 Display per-practice relevance text on each practice card in `SuggestionView`
- [x] 5.7 Add developer-visible Pro escalation indicator (brief overlay/toast when Pro was used)
- [x] 5.8 Build and verify the full flow: record → transcribe → analyze → suggest → reflect

## 6. Tests

- [x] 6.1 Create `siftTests/Services/GeminiServiceTests.swift` — test prompt construction, response parsing, Flash/Pro routing logic, error mapping
- [x] 6.2 Update `RecordingViewModelTests` — test analyzing state transition, Gemini result propagation to session, error-to-retry path
- [x] 6.3 Update `RecordingStateTests` — add `.analyzing` equality test
- [x] 6.4 Create `siftTests/Models/SessionTests.swift` additions — test new Gemini fields default to nil and persist correctly
- [x] 6.5 Update `SwiftDataTests` — verify cascade delete still works with new Session fields
- [x] 6.6 Run `xcodebuild test` and verify all tests pass

## 7. Cleanup

- [x] 7.1 Remove dead code: `Practice.match()` is kept (library reference) but remove unused code paths in ViewModel
- [x] 7.2 Run full test suite: `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- [ ] 7.3 Manual smoke test on simulator: record → get recommendations → try a practice → verify history shows rationale
