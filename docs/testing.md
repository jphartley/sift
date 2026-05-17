# Testing

## Test pyramid

```
        ┌──────────┐
        │  UI (2)  │  Smoke: app launch, tab navigation
        │  ~12s    │  Framework: XCTest (iOS Simulator only)
        ├──────────┤
        │ INT/API  │  View model flows, SwiftData, Gemini collaborators
        │  ~0.3s   │  Framework: Swift Testing + fakes/in-memory SwiftData
        ├──────────┤
        │ UNIT/API │  Models, parsing, prompt building, error mapping
        │  ~0.1s   │  Framework: Swift Testing, no live network
        └──────────┘
```

Unit and integration tests (siftTests) run on both iOS Simulator (~34s) and macOS via Mac Catalyst (~9s warm, no simulator needed).

## Running tests

```bash
# DEFAULT — macOS/Catalyst (no simulator, ~9s warm). Use this for all normal development.
xcodebuild test -scheme sift \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -only-testing:siftTests \
  -skip-testing:siftTests/GeminiBenchmark \
  -enableCodeCoverage NO

# OCCASIONAL — iOS Simulator, unit + integration only (~34s). Use before releases or
# when investigating a platform-specific failure.
xcodebuild test -project sift.xcodeproj -scheme sift \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -skip-testing:siftUITests

# iOS Simulator — full suite including UI tests (~50s)
xcodebuild test -project sift.xcodeproj -scheme sift \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Specific test suite (iOS Simulator)
xcodebuild test -project sift.xcodeproj -scheme sift \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:siftTests/PracticeLibraryTests
```

> **Note on `-enableCodeCoverage NO`**: required for the Catalyst destination. `yyjson` (a WhisperKit transitive C dependency) fails to link against the LLVM profiling runtime on Mac Catalyst when coverage instrumentation is enabled.

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

## Benchmarks

`siftTests/GeminiBenchmark.swift` measures end-to-end Gemini recommendation latency (20 iterations, 5 fixture transcripts). It is **excluded from the default test run** — it requires an explicit opt-in so it doesn't slow down normal `xcodebuild test` invocations.

**Run it:**

```bash
./scripts/run-benchmark.sh
```

The script passes `-testenv RUN_BENCHMARKS=1` and targets `-only-testing:siftTests/GeminiBenchmark`. It reads the API key from `sift/Services/GeminiAPIKey.local` (the same gitignored file the app uses). The benchmark skips automatically if the key is absent.

**Output:** lines prefixed with `BENCHMARK` are emitted to stdout in a machine-parseable format:

```
BENCHMARK iter=1 ms=1243 model=gemini-1.5-flash conf=0.82 escalated=false experiments=baseline
```

## What's not tested (yet)

- `AudioRecorderService` — `AVAudioRecorder` is available on Mac Catalyst so `AudioRecorderServiceTests` compile and run on macOS, but live microphone recording is still untested (no real mic in CI or automated runs)
- `TranscriptionService.loadModel()` / `transcribe()` — requires WhisperKit model download (~150MB) and real audio
- Real Gemini network calls — covered through prompt, parser, router, and facade tests with fake requesters
- Edge cases: force-quit during save, concurrent sessions, long-term history growth
