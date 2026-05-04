# Testing

## Test pyramid

```
        ┌──────────┐
        │  UI (2)  │  Smoke: app launch, tab navigation
        │  ~12s    │  Framework: XCTest
        ├──────────┤
        │  INT (8) │  State machine, cascade delete, predicates, ranking
        │  ~0.07s  │  Framework: Swift Testing + in-memory SwiftData
        ├──────────┤
        │ UNIT (20)│  Pure functions, model defaults, enum equality
        │  ~0.03s  │  Framework: Swift Testing, no dependencies
        └──────────┘
```

## Running tests

```bash
# Run everything (unit + integration + UI)
xcodebuild test -project sift.xcodeproj -scheme sift \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Unit and integration only (fast feedback)
xcodebuild test -project sift.xcodeproj -scheme sift \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -skip-testing:siftUITests

# Specific test suite
xcodebuild test -project sift.xcodeproj -scheme sift \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:siftTests/PracticeLibraryTests
```

## Frameworks

| Test type | Framework | Import |
|-----------|-----------|--------|
| Unit tests | Swift Testing | `import Testing` |
| Integration tests | Swift Testing + SwiftData | `import Testing` + `import SwiftData` |
| UI tests | XCTest | `import XCTest` |

Swift Testing is used for everything except UI tests. `XCUIApplication` requires XCTest. The two frameworks coexist in separate test targets.

## In-memory SwiftData

Integration tests never touch disk. Use the shared helper:

```swift
let container = try TestHelpers.makeContainer()
let context = container.mainContext
```

Implementation in `siftTests/TestHelpers.swift`:

```swift
@MainActor
static func makeContainer() throws -> ModelContainer {
    let schema = Schema([Session.self, PracticeAttempt.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}
```

Each test creates its own container, inserts seed data, and tears down after. No state leaks between tests.

## @MainActor considerations

The project sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Test suites that interact with `@Observable` types or SwiftData contexts must be annotated:

```swift
@MainActor
struct RecordingViewModelTests {
    @Test func myTest() throws {
        let (viewModel, container) = try makeViewModel()
        // ...
    }
}
```

## File organization

```
siftTests/
    TestHelpers.swift                      — shared in-memory container factory
    Models/
        PracticeLibraryTests.swift         — keyword matching (5 tests) + library integrity (3 tests)
        SessionTests.swift                 — model defaults (3 tests)
        PracticeAttemptTests.swift         — model defaults (4 tests)
        SwiftDataTests.swift               — cascade delete + predicate filtering (2 tests)
    ViewModels/
        RecordingStateTests.swift          — enum equality (4 tests)
        RecordingViewModelTests.swift      — state transitions + persistence + ranking (5 tests)
    Services/
        TranscriptionServiceTests.swift    — error descriptions + ModelState equality (4 tests)
siftUITests/
    siftUITests.swift                      — app launch + tab navigation (2 tests)
```

## What's not tested (yet)

- `AudioRecorderService` — requires `AVAudioRecorder` and a real microphone
- `TranscriptionService.loadModel()` / `transcribe()` — requires WhisperKit model download (~150MB) and real audio
- Full end-to-end check-in flow — requires protocol extraction for dependency injection
- Edge cases: interrupted recordings, force-quit during save, concurrent sessions

These are gated by a future refactor that extracts protocols for the audio and transcription services.
