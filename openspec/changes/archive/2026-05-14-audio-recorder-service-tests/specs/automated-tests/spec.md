## ADDED Requirements

### Requirement: Tests cover AudioRecorderService directly
The system SHALL have direct unit tests for `AudioRecorderService` that do not rely on `RecordingViewModel` or `FakeAudioRecorder`.

#### Scenario: Initial state tests run without hardware
- **WHEN** automated tests verify `AudioRecorderService` default property values
- **THEN** the tests SHALL instantiate `AudioRecorderService` directly
- **THEN** the tests SHALL NOT require microphone permission or a real audio session

#### Scenario: startRecording tests use a fake recorder factory
- **WHEN** automated tests verify `startRecording()` behavior
- **THEN** the tests SHALL inject a fake `AVAudioRecorderFactory` to avoid touching real audio hardware
- **THEN** the tests SHALL assert the URL path extension, recording settings, and isRecording state

#### Scenario: stopRecording tests verify state reset
- **WHEN** automated tests verify `stopRecording()` behavior
- **THEN** the tests SHALL assert that `isRecording` is false after stop
- **THEN** the tests SHALL assert that calling `stopRecording()` on an idle instance does not throw
