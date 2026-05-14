## Context

`AudioRecorderService` wraps `AVAudioRecorder`, `AVAudioSession`, and `AVAudioApplication` — all concrete AVFoundation types with no existing seams for injection. Its current 31.5% line coverage comes from app startup paths in `ProjectMetadataTests`, not from targeted behavioral tests. `RecordingViewModel` tests use `FakeAudioRecorder` (the `AudioRecording` protocol), so none of `AudioRecorderService`'s own lines are exercised there. The goal is direct tests for the service's observable state behavior without requiring real hardware or a full app launch.

## Goals / Non-Goals

**Goals:**
- Test `AudioRecorderService` initial state (isRecording, audioLevel, recordingDuration defaults)
- Test `stopRecording()` resets state correctly when called on an idle instance
- Test `startRecording()` sets isRecording and returns a `.wav` URL with the correct format, without requiring real audio hardware
- Test recording settings (sample rate, channels, bit depth, metering enabled)
- Keep tests fast and simulator-independent

**Non-Goals:**
- Testing `requestPermission()` — AVAudioApplication permission APIs are not mockable without entitlement-level test infrastructure; permission behavior is sufficiently covered via `RecordingViewModelTests`
- Testing the meter polling Timer in real time — timer-driven updates require `RunLoop` manipulation that adds more complexity than value at this stage
- Replacing indirect ViewModel tests — these remain valid integration coverage

## Decisions

**Inject an `AVAudioRecorderFactory` protocol instead of calling `AVAudioRecorder(url:settings:)` directly.**

`startRecording()` currently creates `AVAudioRecorder` inline. Extracting creation to a single-method factory protocol (`makeRecorder(url:settings:) throws -> AVAudioRecorderProtocol`) lets tests inject a `FakeAVAudioRecorder` that captures the URL and settings passed to it without touching the audio subsystem.

Alternatives considered:
- *Subclass `AudioRecorderService` in tests and override startRecording* — fragile, fights `@Observable` final class
- *Use `@testable import` and manipulate private state* — tests become brittle to implementation details
- *Accept the indirect coverage and add no new seam* — leaves startRecording untested; the factory seam is small and keeps the production path identical

**Wrap `AVAudioRecorder` behind a minimal `AVAudioRecorderProtocol`.**

The fake only needs `record()`, `stop()`, `updateMeters()`, `averagePower(forChannel:)`, `currentTime`, and `isMeteringEnabled`. This is a narrow surface — no risk of over-abstracting.

**Default production factory uses the real `AVAudioRecorder`; tests supply the fake.**

`AudioRecorderService.init` gains an optional `recorderFactory` parameter defaulting to the real implementation. No call sites change.

## Risks / Trade-offs

- [AVAudioSession.setCategory/setActive may still throw in a headless test environment] → Wrap `AVAudioSession` calls in the same factory boundary or accept that `startRecording()` tests require a simulator with an audio session. Simulator audio sessions are available in `xcodebuild test` runs; this is acceptable.
- [Adding a protocol seam to AVAudioRecorder adds a thin indirection layer] → The protocol has six members and the production factory is two lines. Maintenance cost is negligible.
- [Timer polling remains untested] → Acceptable for now; meter update behavior is an indirect concern of `RecordingViewModel` which already has teardown tests.
