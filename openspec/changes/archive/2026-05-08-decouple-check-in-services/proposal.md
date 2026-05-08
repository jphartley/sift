## Why

The voice check-in flow is currently difficult to test end to end because `RecordingViewModel` is coupled to concrete recorder, transcription, Gemini, and SwiftData implementations. Decoupling those dependencies will let tests exercise the real flow with fakes, catch persistence/error regressions, and make future memory and recommendation work safer to build.

## What Changes

- Introduce small protocols for the services used by the check-in flow: audio recording, transcription, recommendation, and session persistence/history.
- Update production services to conform to those protocols without changing user-facing behavior.
- Refactor `RecordingViewModel` to depend on protocol abstractions and a session store instead of concrete services and direct SwiftData fetch/save calls.
- Add focused test fakes that can simulate successful transcription/recommendation, service failures, persistence failures, and prior session history.
- Replace tests that manually duplicate production behavior with tests that call the actual view model methods.
- Preserve existing app launch environment injection patterns and the current SwiftData data model.

## Capabilities

### New Capabilities
- `check-in-service-abstractions`: Defines injectable service boundaries for the voice check-in flow and the expected testability guarantees.

### Modified Capabilities
- `voice-check-in`: The check-in flow must preserve existing user-facing recording, transcription, analysis, suggestion, retry, and persistence behavior while using injectable dependencies.
- `automated-tests`: Automated tests must verify the real view model flow through protocol-backed fakes rather than manually reproducing model persistence.
- `gemini-practice-recommendation`: Recommendation behavior must be accessible through an injectable client boundary while preserving Flash/Pro routing and persisted Gemini metadata.

## Impact

- Affected app code: `RecordingViewModel`, `AudioRecorderService`, `TranscriptionService`, `GeminiService`, SwiftData session persistence, and `RecordingScreen` configuration.
- Affected tests: `RecordingViewModelTests`, service tests, and any helpers that configure practices or in-memory SwiftData.
- No schema migration is expected because `Session` and `PracticeAttempt` remain structurally unchanged.
- No new third-party dependencies are expected.
