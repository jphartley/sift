## 1. Test infrastructure

- [x] 1.1 Add `siftTests` target to `sift.xcodeproj/project.pbxproj` — unit test bundle, host app not required, deployment target matches app (26.4)
- [x] 1.2 Add `siftUITests` target to `sift.xcodeproj/project.pbxproj` — UI test bundle, requires host app
- [x] 1.3 Create `siftTests/` directory structure mirroring source: `Models/`, `ViewModels/`, `Services/`

## 2. Practice library tests

- [x] 2.1 Create `siftTests/Models/PracticeLibraryTests.swift` — test `Practice.match()` with empty transcript, single keyword, multi-keyword, short-word filtering, compound scoring
- [x] 2.2 Add library integrity tests — unique IDs, non-empty keywords, positive durations for all 10 practices
- [x] 3.1 Create `siftTests/Models/SessionTests.swift` — test default init (empty attempts), custom init preserves values
- [x] 3.2 Create `siftTests/Models/PracticeAttemptTests.swift` — test default init (completed=true, wasHelpful=nil), custom init preserves wasHelpful and notes
- [x] 4.1 Create `siftTests/ViewModels/RecordingStateTests.swift` — test equality for same/different cases, associated value comparison
- [x] 4.2 Create `siftTests/Services/TranscriptionServiceTests.swift` — test TranscriptionError.errorDescription returns non-empty strings for all cases, test ModelState equality
- [x] 5.1 Create helper `makeContainer()` in a shared test utility — in-memory SwiftData container for Session + PracticeAttempt
- [x] 5.2 Create `siftTests/ViewModels/RecordingViewModelTests.swift` — test `logPractice` state transition and attempt creation
- [x] 5.3 Test `completeReflection` — persists Session + attempt, resets state to `.ready`, sets wasHelpful and notes
- [x] 5.4 Test `skipSuggestions` — persists empty Session, resets state to `.ready`
- [x] 5.5 Test `dismissPractice` — clears attempts, transitions back to `.suggesting`
- [x] 6.1 Test practice ranking with previously-helpful boost — verify +2 bonus sorts above equal matches
- [x] 6.2 Test SwiftData cascade delete — deleting Session removes its PracticeAttempts
- [x] 6.3 Test FetchDescriptor predicate — wasHelpful == true returns only matching attempts
- [x] 7.1 Create `siftUITests/siftUITests.swift` — launch app, verify "Record" and "History" tabs exist
- [x] 7.2 Tap History tab, verify empty state content appears
- [x] 8.1 Run `xcodebuild test` and confirm all tests pass
- [x] 8.2 Clean up unused imports and stale comments in test files
