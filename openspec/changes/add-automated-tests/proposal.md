## Why

The project has zero automated tests, leaving every code change unverified until manually tested on device or simulator. Adding a first round of tests now — against the stable voice check-in MVP — creates a safety net for future iterations and catches regressions early. The pure functions, data models, and ViewModel state machine are immediately testable without architectural changes.

## What Changes

- Add a `siftTests` target to the Xcode project for unit and integration tests
- Unit tests for `PracticeLibrary.match()` keyword matching (pure function, no dependencies)
- Unit tests for data model initialization and relationships (`Session`, `PracticeAttempt`)
- Unit tests for `RecordingState` enum and `TranscriptionError`/`ModelState` enums
- Integration tests for `RecordingViewModel` state transitions using in-memory SwiftData (logPractice, completeReflection, skipSuggestions flow)
- Integration tests for practice ranking with previously-helpful boosting via in-memory SwiftData
- A basic UI smoke test target (`siftUITests`) that verifies app launch and tab presence
- No protocol extraction or mocking of `AudioRecorderService` / `TranscriptionService` (kept for a future refactor)

## Capabilities

### New Capabilities
- `automated-tests`: Unit and integration tests covering the pure logic, data models, and ViewModel state machine with in-memory SwiftData. Verifies keyword matching, practice ranking, reflection persistence, and state transitions.

### Modified Capabilities
<!-- No existing specs to modify. -->

## Impact

- New `siftTests/` directory with test files
- New `siftUITests/` directory with UI smoke test
- `sift.xcodeproj/project.pbxproj` modified to add test targets
- No source code changes to the app target (tests only)
- Build pipeline must run `xcodebuild test` with the test destinations
