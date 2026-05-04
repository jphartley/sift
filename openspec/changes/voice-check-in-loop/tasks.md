## 1. Data model changes

- [x] 1.1 Delete `Models/TestResult.swift`
- [x] 1.2 Create `Models/Session.swift` — `@Model` class with fields: `id` (UUID), `timestamp` (Date), `transcript` (String), `audioDuration` (TimeInterval), `transcriptionDurationMs` (Int). Add one-to-many relationship to `PracticeAttempt`.
- [x] 1.3 Create `Models/PracticeAttempt.swift` — `@Model` class with fields: `id` (UUID), `practiceID` (String), `practiceName` (String), `timestamp` (Date), `completed` (Bool), `wasHelpful` (Bool?), `notes` (String?). Add inverse relationship to `Session`.
- [x] 1.4 Create `Models/PracticeLibrary.swift` — non-`@Model` file with a `Practice` struct (id, name, category, keywords, description, durationMinutes) and a `static let all: [Practice]` array of 10 curated practices across categories (breathwork, movement, journaling, social, nature, sensory).
- [x] 1.5 Update `siftApp.swift` — replace `TestResult.self` with `Session.self, PracticeAttempt.self` in the `ModelContainer` configuration.

## 2. Suggestion engine

- [x] 2.1 Add keyword matching function to `PracticeLibrary` — takes a transcript string, lowercases it, returns practices ranked by keyword hit count.
- [x] 2.2 Add "previously helpful" boosting — query SwiftData for past `PracticeAttempt`s where `wasHelpful == true`, sort practices by recency of helpful attempts as a tiebreaker.

## 3. RecordingViewModel overhaul

- [x] 3.1 Remove `accuracyRating`, `intentCaptureRating`, `referenceText`, `failureReason` properties from `RecordingViewModel`.
- [x] 3.2 Remove `.result(transcript:latencyMs:)` from `RecordingState` enum and replace with `.suggesting(transcript:String, practices:[Practice])` and `.reflecting(session:Session, attempt:PracticeAttempt)` cases.
- [x] 3.3 Update `stopRecording()` — after transcription completes, run keyword matching and transition to `.suggesting` with the transcript and suggested practices.
- [x] 3.4 Add `logPractice(practiceID:practiceName:completion:)` method — creates a `PracticeAttempt`, transitions to `.reflecting`.
- [x] 3.5 Add `completeReflection(wasHelpful:notes:)` method — updates the `PracticeAttempt`, persists the `Session`, resets to `.ready`.
- [x] 3.6 Add `skipReflection()` method — returns to `.ready` without saving.
- [x] 3.7 Remove `saveResult()` and `discardResult()` (replaced by the reflection flow above).

## 4. UI — Practice suggestion view

- [x] 4.1 Delete `Views/ResultScreen.swift` (the accuracy-rating form).
- [x] 4.2 Create `Views/SuggestionView.swift` — displays the transcript in a gray rounded rectangle, then 2–3 practice cards. Each card shows: practice name, category, duration estimate, brief description. Tapping a card calls `logPractice()`.
- [x] 4.3 Add "Previously helped" badge to practice cards when the practice was marked helpful in a prior session.
- [x] 4.4 Create `Views/ReflectionView.swift` — displays the practice name, asks "Did you try [practice]?" with Yes/No buttons. If Yes, shows thumbs up / thumbs down for helpfulness. Optional notes TextField. Save button persists and returns to ready. Skip returns to ready without saving.

## 5. UI — Recording screen and history

- [x] 5.1 Update `Views/RecordingScreen.swift` — handle `.suggesting` and `.reflecting` states by delegating to `SuggestionView` and `ReflectionView` respectively.
- [x] 5.2 Delete `Views/HistoryScreen.swift` (the TestResult-based list).
- [x] 5.3 Create new `Views/HistoryScreen.swift` — `@Query` for `Session` sorted by timestamp descending. Each row shows: date, transcript preview (2 lines), practice count, and helpfulness summary (e.g., "2 helpful, 1 not"). Swipe-to-delete removes the session and cascades to its attempts.
- [x] 5.4 Create `Views/SessionDetailView.swift` — tapped from history, shows full transcript and a list of practice attempts with their helpfulness ratings.

## 6. Final cleanup

- [x] 6.1 Verify the project builds (`xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`).
- [x] 6.2 Remove any remaining references to `TestResult`, accuracy rating, intent capture, reference text, failure reason across the codebase.
- [x] 6.3 Clean up unused imports and stale comments.
