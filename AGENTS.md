# Sift

iOS wellness companion app — SwiftUI + SwiftData + WhisperKit.

## Agent Instructions

### Core Workflow
- Focus on correctness and project alignment.
- Every behavior change MUST update or add tests. Run `xcodebuild test` before committing.
- Only after the task is complete, perform a cleanup pass: remove dead code, unused imports, stale comments; reduce unnecessary abstraction; align with project patterns and conventions. Do not expand scope during this pass.
- Commit frequently in small, logical, verified units. Use descriptive messages (e.g., `feat: add user validation`, `fix: resolve import error`).

### Struggle Protocol
If a task fails or you are stuck:
1. Halt immediately.
2. Inspect logs and recent changes for the root cause.
3. State 1–2 reasons for the failure.
4. Validate against existing project patterns.
5. If the second attempt fails, summarize and ask the user for direction.

### Maintenance
- Keep this file lean. Move detailed patterns, API references, and architecture guides to `/docs/` or knowledge base files.
- See `/docs/` for the PRD, memory architecture supplement, and WhisperKit decision rationale.

## Current phase

This is the **voice check-in MVP** — the first product-feature iteration after the transcription validation prototype. The app's core loop: record voice note → transcribe on-device with WhisperKit → get 2–3 wellness practice suggestions (keyword-matched from a curated library) → try one → reflect on helpfulness. Session and practice attempt history persisted via SwiftData. LLM post-processing, HealthKit, and full conversational memory are out of scope.

## Build & run

- Open `sift.xcodeproj` in Xcode (built with Xcode 26.4.1).
- Single target `sift`. Single SPM dependency: WhisperKit (≥0.8.0, from `https://github.com/argmaxinc/WhisperKit.git`).
- CLI build: `xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- CLI test (all): `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- CLI test (unit/integration only, skip slow UI): append ` -skip-testing:siftUITests`
- Single SPM dependency: WhisperKit (≥0.8.0, from `https://github.com/argmaxinc/WhisperKit.git`).
- No CI, no lint config yet.

## Architecture

```
sift/
  siftApp.swift           — @main entry, sets up SwiftData ModelContainer for Session + PracticeAttempt
  ContentView.swift       — TabView with "Check In" and "History" tabs
  Models/
    Session.swift         — @Model: one voice check-in, transcript + duration + attempts relationship
    PracticeAttempt.swift — @Model: one practice trial, linked to session, with helpfulness rating
    PracticeLibrary.swift — Practice struct + 10 curated practices + keyword matcher
  Services/
    AudioRecorderService.swift  — AVAudioRecorder (PCM 16kHz mono WAV, temp file)
    TranscriptionService.swift  — WhisperKit wrapper, loads "openai_whisper-base.en" model
  ViewModels/
    RecordingViewModel.swift    — orchestrator: owns both services, manages RecordingState enum
  Views/
    RecordingScreen.swift       — record button, audio level meter, delegates to flow views
    SuggestionView.swift        — transcript display + 2–3 practice cards with "Helped before" badge
    ReflectionView.swift        — "Did you try it?" → thumbs up/down → optional notes → save
    HistoryScreen.swift         — SwiftData @Query list of past sessions, swipe to delete
    SessionDetailView.swift     — full transcript + practice attempts with helpfulness ratings
siftTests/
    TestHelpers.swift                      — in-memory SwiftData container factory
    Models/
      PracticeLibraryTests.swift           — keyword matching + library integrity
      SessionTests.swift                   — model defaults
      PracticeAttemptTests.swift           — model defaults
      SwiftDataTests.swift                 — cascade delete + predicate filtering
    ViewModels/
      RecordingStateTests.swift            — enum equality
      RecordingViewModelTests.swift        — state transitions + persistence + ranking
    Services/
      TranscriptionServiceTests.swift      — error descriptions + ModelState equality
siftUITests/
    siftUITests.swift                      — app launch + tab navigation smoke test
```

## Conventions

  - **Testing**:
  - Every change that modifies behavior MUST update or add corresponding tests.
  - OpenSpec change proposals MUST include test-related tasks (new tests, updated tests).
  - Tests use Swift Testing (`import Testing`) — not XCTest — except UI tests which use XCTest (`import XCTest`) for `XCUIApplication`.
  - Integration tests use in-memory SwiftData (`ModelConfiguration(isStoredInMemoryOnly: true)`); never write to disk.
  - Test file organization mirrors source: `siftTests/Models/`, `siftTests/ViewModels/`, etc.
  - Run `xcodebuild test` before committing. A commit that breaks tests is invalid.
  - For fast feedback during development, skip the slow UI tests: `xcodebuild test ... -skip-testing:siftUITests`
  - See `/docs/testing.md` for detailed patterns and the test pyramid.
- **Actor isolation**: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set. Types default to `@MainActor` unless explicitly annotated otherwise.
- **Observation**: Uses `@Observable` (Swift 6 Observation framework), not `@ObservableObject`/`@Published`.
- **SwiftData**: `@Model` for persistence, `@Query` for reads. Container configured in `siftApp.swift`.
- **No comments**: The codebase intentionally omits comments. Do not add them.
- Deployment target: iOS 26.4 (bleeding-edge — assumes Swift 6, full structured concurrency).


