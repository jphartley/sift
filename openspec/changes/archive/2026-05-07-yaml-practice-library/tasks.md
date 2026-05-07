## 1. Add Yams dependency

- [x] 1.1 Add Yams SPM package to Xcode project (https://github.com/jpsim/Yams.git, latest stable)
- [x] 1.2 Verify project builds with new dependency

## 2. Create practices.yaml resource file

- [x] 2.1 Create `Resources/practices.yaml` with all 10 existing practices in YAML format
- [x] 2.2 Add `practices.yaml` to the app target's Copy Bundle Resources in Xcode
- [x] 2.3 Verify the file appears in the bundle at runtime

## 3. Update Practice model for YAML decoding

- [x] 3.1 Add `Decodable` conformance to `Practice` struct
- [x] 3.2 Add `CodingKeys` enum mapping `duration_minutes` → `durationMinutes`
- [x] 3.3 Add wrapper struct (e.g., `PracticeContainer`) for decoding the top-level `practices` key
- [x] 3.4 Remove the static `Practice.all` array
- [x] 3.5 Add static `load()` method that decodes from `Bundle.main` via Yams, returning `[Practice]` or throwing

## 4. Remove keyword matcher

- [x] 4.1 Remove `match(transcript:)` static method from `Practice` / `PracticeLibrary.swift`
- [x] 4.2 Remove `keywords` field from Practice if no longer needed (keep for Gemini prompt context)

## 5. Update consumers

- [x] 5.1 Update `GeminiService.buildPrompt()` to use the new practice loading mechanism
- [x] 5.2 Update `RecordingViewModel` practice lookup to use new loading mechanism
- [x] 5.3 Ensure app launch loads practices and surfaces errors if YAML is missing/malformed

## 6. Update tests

- [x] 6.1 Add test helper for loading practices from in-memory YAML strings
- [x] 6.2 Remove keyword matching tests from `PracticeLibraryTests.swift`
- [x] 6.3 Add tests for YAML decoding: valid practice, unknown keys ignored, malformed YAML failure
- [x] 6.4 Add bundle validation test: decodes the real `practices.yaml` from the test bundle and asserts non-empty
- [x] 6.5 Update `RecordingViewModelTests.swift` to use in-memory YAML instead of `Practice.all`
- [x] 6.6 Update `GeminiServiceTests.swift` `promptIncludesPracticeLibrary` test to use in-memory YAML

## 7. Build and verify

- [x] 7.1 Run `xcodebuild build` to confirm clean compilation
- [x] 7.2 Run `xcodebuild test` (excluding UI tests) to confirm all tests pass
- [x] 7.3 Run full test suite including UI tests
