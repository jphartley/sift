## Why

Users can already record longer voice check-ins, but on iPhone the screen can still go to sleep during an active recording. That interrupts the experience and risks cutting off a reflective check-in that may legitimately run for several minutes.

## What Changes

- Keep the device screen awake while a voice check-in recording is actively in progress.
- Restore normal idle behavior as soon as recording stops, fails, or the recording screen is torn down.
- Limit the behavior to the recording lifecycle so setup, transcription, and analysis do not keep the screen awake unnecessarily.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `voice-check-in`: the recording flow must prevent screen sleep during active recording and must return to normal idle behavior when recording ends or the screen disappears.

## Impact

- `sift/Views/RecordingScreen.swift`
- `sift/ViewModels/RecordingViewModel.swift`
- A small screen-idle control abstraction or equivalent lifecycle hook
- `siftTests/ViewModels/RecordingViewModelTests.swift` and any related recording lifecycle tests
- OpenSpec `voice-check-in` spec coverage
