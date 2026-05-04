## Context

The sift app has no test targets, no test files, and no test automation. All verification is manual. The codebase has several pure functions (`PracticeLibrary.match`, model initializers) and a ViewModel with clear state transitions that are immediately testable. The audio and transcription services (`AudioRecorderService`, `TranscriptionService`) directly instantiate `AVAudioRecorder` and `WhisperKit` without protocol abstraction, making them untestable in isolation without refactoring.

## Goals / Non-Goals

**Goals:**
- Add a `siftTests` unit test bundle with tests that run without a simulator (logic-only)
- Cover `PracticeLibrary.match()` with comprehensive keyword-matching test cases
- Cover model initialization defaults and relationships (`Session`, `PracticeAttempt`)
- Cover `RecordingViewModel` state transitions using in-memory SwiftData
- Cover practice ranking logic including previously-helpful boosting
- Achieve build-server-friendly execution: `xcodebuild test` passes on CLI
- Keep tests fast (<5 seconds total for the unit/integration suite)

**Non-Goals:**
- Protocol extraction / dependency injection for audio/transcription services
- Tests that require a real microphone or WhisperKit model download
- UI tests for the recording flow (recording real audio in tests is impractical)
- Code coverage thresholds (too early — establish test culture first)
- Snapshot testing or accessibility testing

## Decisions

### 1. Single test bundle for both unit and integration tests

One `siftTests` target covers both pure-unit tests and SwiftData-integration tests. Separating them adds complexity (two test targets, two schemes) without benefit at this scale. The in-memory SwiftData container makes "integration" tests nearly as fast as pure unit tests.

**Alternatives considered**: Separate `siftUnitTests` and `siftIntegrationTests` targets. Rejected — overkill for a single-developer project with ~10 test files.

### 2. In-memory SwiftData container for ViewModel tests

Tests that need SwiftData use a `ModelContainer` with `isStoredInMemoryOnly: true`. This is instantaneous and isolates tests from each other. Each test creates a fresh container, inserts seed data, and tears down after. No file I/O, no state leakage.

```swift
func makeContainer() throws -> ModelContainer {
    let schema = Schema([Session.self, PracticeAttempt.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}
```

**Alternatives considered**: Mock SwiftData with a protocol layer. Rejected — over-abstracting a first-party framework adds maintenance burden. Apple's in-memory store is purpose-built for testing.

### 3. Test file organization mirrors source structure

```
siftTests/
    Models/
        PracticeLibraryTests.swift
        SessionTests.swift
        PracticeAttemptTests.swift
    ViewModels/
        RecordingViewModelTests.swift
    Services/
        TranscriptionServiceTests.swift
    Resources/
        test-fixture.wav     (16kHz mono WAV with known content, for future use)
```

**Alternatives considered**: Flat test directory. Rejected — mirroring source structure makes it obvious which tests cover which files.

### 4. Swift Testing framework over XCTest

The project targets iOS 26.4 and uses Swift 6 conventions. Swift Testing (`import Testing`) is the modern framework aligned with the project's bleeding-edge posture. It supports `#expect`, parameterized tests, and structured test suites without `XCTestCase` subclass boilerplate.

**Alternatives considered**: XCTest. Rejected — Swift Testing is the forward path for Swift 6 + iOS 26, matches project conventions better, and has cleaner syntax for the test patterns we need.

### 5. Manual Xcode project edits for test target

Add the test target by editing `project.pbxproj` directly rather than using Xcode's GUI. This is reproducible via CLI `xcodebuild` and keeps the change auditable in git diff.

**Alternatives considered**: Use `xcodebuild -create-xcframework` or `swift package init`. Rejected — the project is a `.xcodeproj`, not an SPM package. Manual pbxproj edits are the standard approach for CLI-driven iOS projects.

### 6. Basic UI smoke test using XCTest UI Testing

One `siftUITests` target with a single test: launch the app, verify two tabs exist, tap the History tab, verify it shows the empty state. This catches catastrophic launch failures but doesn't test audio recording. Uses the iOS simulator (required for UI tests).

**Alternatives considered**: More comprehensive UI tests for the full check-in flow. Rejected — recording real audio in UI tests is unreliable. The future integration-test plan (protocol extraction) is a better path for flow testing.

## Risks / Trade-offs

- **Swift Testing is newer than XCTest** → Some CI systems may not support it out of the box. Mitigation: `xcodebuild test` supports Swift Testing natively in Xcode 26.
- **@MainActor isolation complicates async tests** → ViewModel methods are `@MainActor` by project convention. Mitigation: annotate test functions with `@MainActor` or use `await MainActor.run`.
- **No coverage of audio/transcription path** → A bug in the recording or transcription layer won't be caught. Mitigation: acknowledged gap. Protocol extraction in a future refactor will address this.
- **Manual pbxproj edits are error-prone** → Typos or missing references can break the build. Mitigation: verify immediately with `xcodebuild test` after editing.

## Open Questions

- Should the test target deployment target match the app (iOS 26.4) or be lower? (Recommendation: match app target for consistency)
- Should the UI test target be created now or deferred? (Recommendation: create now but keep minimal — one smoke test)
