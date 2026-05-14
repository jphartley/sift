## 1. Add AVAudioRecorder seam to AudioRecorderService

- [x] 1.1 Define `AVAudioRecorderProtocol` with the minimal surface needed: `record()`, `stop()`, `updateMeters()`, `averagePower(forChannel:) -> Float`, `currentTime: TimeInterval`, `isMeteringEnabled: Bool`
- [x] 1.2 Extend `AVAudioRecorder` to conform to `AVAudioRecorderProtocol`
- [x] 1.3 Define `AudioRecorderFactory` protocol: `makeRecorder(url: URL, settings: [String: Any]) throws -> AVAudioRecorderProtocol`
- [x] 1.4 Add a default `RealAudioRecorderFactory` struct that creates a real `AVAudioRecorder`
- [x] 1.5 Add an optional `recorderFactory: AudioRecorderFactory` parameter to `AudioRecorderService.init`, defaulting to `RealAudioRecorderFactory()`
- [x] 1.6 Replace the inline `AVAudioRecorder(url:settings:)` call in `startRecording()` with `recorderFactory.makeRecorder(url:settings:)`
- [x] 1.7 Confirm existing app targets and `RecordingViewModelTests` still build and all tests pass

## 2. Write AudioRecorderServiceTests

- [x] 2.1 Create `siftTests/Services/AudioRecorderServiceTests.swift` with `import Testing`
- [x] 2.2 Add a `FakeAVAudioRecorder` class conforming to `AVAudioRecorderProtocol` that captures `isMeteringEnabled`, `didCallRecord`, `didCallStop`, and the settings passed at construction
- [x] 2.3 Add a `FakeAudioRecorderFactory` that returns a `FakeAVAudioRecorder` and exposes the last-used URL and settings for assertions
- [x] 2.4 Test initial state: `isRecording == false`, `audioLevel == -160`, `recordingDuration == 0`
- [x] 2.5 Test `stopRecording()` on an idle instance does not crash and leaves `isRecording == false`
- [x] 2.6 Test `startRecording()` sets `isRecording = true`
- [x] 2.7 Test `startRecording()` returns a URL with `.wav` extension
- [x] 2.8 Test `startRecording()` passes `AVFormatIDKey == kAudioFormatLinearPCM` to the factory
- [x] 2.9 Test `startRecording()` passes `AVSampleRateKey == 16000.0` to the factory
- [x] 2.10 Test `startRecording()` passes `AVNumberOfChannelsKey == 1` to the factory
- [x] 2.11 Test `startRecording()` sets `isMeteringEnabled = true` on the fake recorder
- [x] 2.12 Test `stopRecording()` after `startRecording()` sets `isRecording = false`

## 3. Verify

- [x] 3.1 Run `xcodebuild test` and confirm all new tests pass with no regressions
- [x] 3.2 Check coverage report — `AudioRecorderService.swift` line coverage should increase meaningfully from 31.5%
