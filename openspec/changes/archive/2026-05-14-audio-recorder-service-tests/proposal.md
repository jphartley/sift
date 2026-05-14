## Why

`AudioRecorderService` is only tested indirectly through `RecordingViewModel` using `FakeAudioRecorder`, so its own behavior — state initialization, recording lifecycle, and stopRecording idempotency — is unverified by the test suite. This is the first of three targeted coverage gaps identified in `docs/tech-debt.md` following the code coverage reporting work.

## What Changes

- Add a direct unit test file `siftTests/Services/AudioRecorderServiceTests.swift`
- Introduce an injectable `AudioRecorderFactory` protocol to `AudioRecorderService` so tests can supply a fake `AVAudioRecorder` without hitting hardware
- Add tests covering: initial state, `stopRecording` idempotency, `startRecording` state transitions, recording settings, and metering setup

## Capabilities

### New Capabilities
- `audio-recorder-service-tests`: Direct unit tests for `AudioRecorderService` verifying state initialization, `startRecording` configuration, and `stopRecording` reset behavior

### Modified Capabilities
- `automated-tests`: New `AudioRecorderService` coverage scenarios are added to the test requirements

## Impact

- `sift/Services/AudioRecorderService.swift` — add injectable recorder factory; no behavior change
- `siftTests/Services/AudioRecorderServiceTests.swift` — new file
- `openspec/specs/automated-tests/spec.md` — new requirements added
