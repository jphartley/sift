## Why

First-time setup can take long enough for beta users to think Sift is stuck, especially while WhisperKit downloads or compiles the on-device speech model. The first microphone tap can also feel unresponsive while permission and recorder setup resolve, so the app should make both waiting moments feel expected, alive, and worth trusting.

## What Changes

- Replace the sparse model-loading view with a first-time setup experience that explains what Sift is preparing and why it may take a moment.
- Show clear phase-specific copy for downloading and preparing on-device speech recognition.
- Preserve visible progress during downloads and a reassuring active loading state during local model preparation.
- Immediately acknowledge the first microphone tap with a "getting microphone ready" state while permission and recorder startup are in progress.
- Prevent repeated mic taps from starting overlapping setup work while the first tap is being handled.
- Keep the user-facing privacy promise clear: speech recognition is being prepared on the device.
- Add test coverage for the setup copy, phase-specific presentation, microphone-start transition, and storage-directory preparation.
- Reduce first-launch CoreData noise by ensuring the app support directory exists before SwiftData initializes.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `voice-check-in`: Updates first-launch model-loading and first microphone-start behavior so users see reassuring progress instead of generic loading or apparent unresponsiveness.
- `automated-tests`: Adds coverage expectations for first-time setup presentation, model-loading phase copy, and microphone-start acknowledgement.

## Impact

- `sift/Views/RecordingScreen.swift`
- `sift/ViewModels/RecordingViewModel.swift`
- Potential small presentation type near `RecordingScreenOrientation` for first-time setup copy.
- `siftTests/Views/` and `siftTests/ViewModels/` coverage for setup presentation and mic-start state.
- App startup directory preparation in `sift/siftApp.swift`.
- No change to Whisper model choice, recommendation behavior, privacy tab content, or persistence schema.
