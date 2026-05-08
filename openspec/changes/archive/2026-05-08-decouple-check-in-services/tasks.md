## 1. Service Boundaries

- [x] 1.1 Define `AudioRecording`, `TranscriptionClient`, `RecommendationClient`, and `SessionStore` protocols scoped to current check-in flow needs.
- [x] 1.2 Make `AudioRecorderService`, `TranscriptionService`, and `GeminiService` conform to the new protocols without changing production behavior.
- [x] 1.3 Add `SwiftDataSessionStore` for saving sessions and loading recommendation history from `ModelContext`.
- [x] 1.4 Ensure session store save methods throw errors instead of silently swallowing SwiftData failures.

## 2. View Model Refactor

- [x] 2.1 Update `RecordingViewModel` to receive protocol dependencies through initialization or configuration.
- [x] 2.2 Replace direct SwiftData fetch/save calls in `RecordingViewModel` with `SessionStore` calls.
- [x] 2.3 Extract repeated recommendation-to-suggestion-state assembly into a single helper.
- [x] 2.4 Extract repeated successful-save reset behavior into a single helper.
- [x] 2.5 Surface transcription, recommendation, and save failures through testable error states without losing retry context.
- [x] 2.6 Preserve existing successful check-in, reflection, skip, dismiss, and retry behavior.

## 3. App Wiring

- [x] 3.1 Update `RecordingScreen` to construct or configure `RecordingViewModel` with production protocol dependencies.
- [x] 3.2 Keep app-level ownership of long-lived `TranscriptionService` and `GeminiService` through the SwiftUI environment.
- [x] 3.3 Verify model-load failure retry behavior is still correct after dependency changes.

## 4. Test Fakes

- [x] 4.1 Add fake audio recorder, transcription client, recommendation client, and session store helpers for tests.
- [x] 4.2 Make fakes configurable for success, failure, saved session capture, and returned history.
- [x] 4.3 Keep fakes minimal and local to the test target unless production previews also need them.

## 5. Flow Tests

- [x] 5.1 Rewrite reflection completion tests to call `completeReflection` and assert saved session/attempt data.
- [x] 5.2 Rewrite skip suggestion tests to call `skipSuggestions` and assert a session without attempts is saved.
- [x] 5.3 Add a successful stop-recording test that drives fake transcription and recommendation into `.suggesting`.
- [x] 5.4 Add a recommendation failure test that verifies error state and retry context.
- [x] 5.5 Add a session save failure test that verifies the flow does not silently reset.
- [x] 5.6 Add a history handoff test that verifies session store history reaches the recommendation client.
- [x] 5.7 Add a no-resolvable-practices test that verifies an error or empty state instead of successful empty suggestions.

## 6. Cleanup and Verification

- [x] 6.1 Remove obsolete tests that manually duplicate production persistence behavior.
- [x] 6.2 Remove unused imports, stale helper code, and unnecessary abstraction introduced during the refactor.
- [x] 6.3 Update `AGENTS.md` if the architecture section or testing conventions need changes after implementation.
- [x] 6.4 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -skip-testing:siftUITests`.
- [x] 6.5 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
