# Testing

## Test pyramid

```
        ┌──────────┐
        │  UI (2)  │  Smoke: app launch, tab navigation
        │  ~12s    │  Framework: XCTest
        ├──────────┤
        │ INT/API  │  View model flows, SwiftData, Gemini collaborators
        │  ~0.3s   │  Framework: Swift Testing + fakes/in-memory SwiftData
        ├──────────┤
        │ UNIT/API │  Models, parsing, prompt building, error mapping
        │  ~0.1s   │  Framework: Swift Testing, no live network
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
        PracticeLibraryTests.swift         — YAML decoding + library integrity
        SessionTests.swift                 — model defaults + Gemini metadata fields
        PracticeAttemptTests.swift         — model defaults
        SwiftDataTests.swift               — cascade delete, session store delete, predicates, Gemini persistence
    ViewModels/
        RecordingStateTests.swift          — enum equality
        RecordingViewModelTests.swift      — fake-backed check-in flow, persistence, retry, cancellation, failure paths
        HistoryViewModelTests.swift        — fake-backed history deletion success and failure paths
    Services/
        GeminiPromptBuilderTests.swift     — prompt construction without live network
        GeminiRecommendationParserTests.swift — structured JSON parsing and validation
        GeminiRecommendationRouterTests.swift — Flash/Pro routing and retry classification
        GeminiServiceTests.swift           — facade-level errors, result data, safe secret fallback
        TranscriptionServiceTests.swift    — error descriptions + ModelState equality/idempotence
siftUITests/
    siftUITests.swift                      — app launch + tab navigation (2 tests)
```

## What's not tested (yet)

- `AudioRecorderService` — requires `AVAudioRecorder` and a real microphone
- `TranscriptionService.loadModel()` / `transcribe()` — requires WhisperKit model download (~150MB) and real audio
- Real Gemini network calls — covered through prompt, parser, router, and facade tests with fake requesters
- Edge cases: force-quit during save, concurrent sessions, long-term history growth
