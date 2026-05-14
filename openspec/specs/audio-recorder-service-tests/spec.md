## Purpose
Define the unit test coverage expected for `AudioRecorderService`, including initialization defaults, recording configuration, and stop behavior.
## Requirements
### Requirement: AudioRecorderService initializes with correct defaults
The system SHALL initialize `AudioRecorderService` with observable state reflecting an idle, not-recording condition.

#### Scenario: isRecording defaults to false
- **WHEN** an `AudioRecorderService` is initialized
- **THEN** `isRecording` SHALL be `false`

#### Scenario: audioLevel defaults to -160
- **WHEN** an `AudioRecorderService` is initialized
- **THEN** `audioLevel` SHALL be `-160`

#### Scenario: recordingDuration defaults to zero
- **WHEN** an `AudioRecorderService` is initialized
- **THEN** `recordingDuration` SHALL be `0`

### Requirement: startRecording configures the audio recorder correctly
The system SHALL configure the underlying audio recorder with the expected WAV format settings and metering enabled.

#### Scenario: startRecording sets isRecording to true
- **WHEN** `startRecording()` is called with a fake recorder factory
- **THEN** `isRecording` SHALL be `true`

#### Scenario: startRecording returns a WAV URL
- **WHEN** `startRecording()` is called with a fake recorder factory
- **THEN** the returned URL SHALL have a `.wav` path extension

#### Scenario: startRecording uses PCM format
- **WHEN** `startRecording()` is called with a fake recorder factory
- **THEN** the settings passed to the factory SHALL include `AVFormatIDKey` equal to `kAudioFormatLinearPCM`

#### Scenario: startRecording uses 16kHz sample rate
- **WHEN** `startRecording()` is called with a fake recorder factory
- **THEN** the settings passed to the factory SHALL include `AVSampleRateKey` equal to `16000.0`

#### Scenario: startRecording uses mono channel
- **WHEN** `startRecording()` is called with a fake recorder factory
- **THEN** the settings passed to the factory SHALL include `AVNumberOfChannelsKey` equal to `1`

#### Scenario: startRecording enables metering
- **WHEN** `startRecording()` is called with a fake recorder factory
- **THEN** `isMeteringEnabled` on the fake recorder SHALL be `true`

### Requirement: stopRecording resets observable state
The system SHALL reset all observable recording state when `stopRecording()` is called.

#### Scenario: stopRecording sets isRecording to false
- **WHEN** `startRecording()` has been called and then `stopRecording()` is called
- **THEN** `isRecording` SHALL be `false`

#### Scenario: stopRecording is idempotent when not recording
- **WHEN** `stopRecording()` is called on an idle `AudioRecorderService` that has never started recording
- **THEN** no error SHALL be thrown and `isRecording` SHALL remain `false`
