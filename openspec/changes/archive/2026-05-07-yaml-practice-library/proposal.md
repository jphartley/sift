## Why

Practices are currently hardcoded as a static Swift array in `PracticeLibrary.swift`. This makes editing, expanding, and auditing the practice library unnecessarily coupled to source code changes. Moving to an external YAML resource file separates content from code, makes the library easier for humans and LLMs to edit, and opens the door to remote updates without app releases.

## What Changes

- **BREAKING**: Add Yams SPM dependency for YAML parsing (third SPM dependency alongside WhisperKit and GoogleGenerativeAI)
- Add `Resources/practices.yaml` — the practice library in YAML format, bundled with the app
- Replace `Practice.all` static array with YAML file decoding at load time
- Remove the `match(transcript:)` keyword matcher (Gemini is now the sole recommendation engine; keyword matching served as a bridge solution and has zero callers in production code)
- Update `Practice` struct to be `Decodable` for YAML parsing
- Update tests to load practices from YAML (test helpers will decode from bundle or provide in-memory YAML strings)

## Capabilities

### New Capabilities

- `yaml-practice-library`: Practice definitions live in an external YAML resource file, decoded at app launch via Yams. The app must gracefully handle a missing or malformed YAML file with a clear error state.

### Modified Capabilities

- `practice-loop`: The practice library SHALL no longer be "hardcoded." It SHALL be loaded from a bundled YAML resource file. The library remains curated (not user-authored) for the current MVP phase.

## Impact

- New SPM dependency: `Yams` (https://github.com/jpsim/Yams.git)
- Affected files: `PracticeLibrary.swift`, `GeminiService.swift` (prompt builder), `RecordingViewModel.swift` (practice lookup), `PracticeLibraryTests.swift`, `RecordingViewModelTests.swift`, `GeminiServiceTests.swift`
- `Practice.match(transcript:)` removed — no callers outside tests; tests using keyword matching will be updated or removed
- Xcode project file updated to include `Resources/practices.yaml` in the app bundle
