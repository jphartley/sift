## Context

On a clean install, Sift preloads the WhisperKit model at app launch. Logs from manual testing show model preparation taking about 15 seconds on device, and first-launch storage setup may add noisy CoreData diagnostics. The app currently shows a spinner or progress bar with short technical copy, which is accurate but not emotionally enough for a vulnerable beta onboarding moment. Manual testing also showed the first microphone tap feeling unresponsive, causing repeated taps before recording appeared.

## Goals / Non-Goals

**Goals:**

- Make first-time speech setup feel expected, calm, and alive.
- Explain that Sift is preparing on-device speech recognition before the user records.
- Preserve download progress when available.
- Distinguish downloading from local preparation/compilation in simple language.
- Keep existing retry/recovery behavior for model loading failures.
- Acknowledge the microphone tap immediately while permission and recorder startup are pending.
- Ignore repeated microphone taps while startup is already in progress.
- Create the app support directory before SwiftData initializes to reduce first-launch storage diagnostics.
- Add view-adjacent tests for setup copy.
- Add view model tests for the microphone-start transition.

**Non-Goals:**

- Changing the WhisperKit model, download source, or caching behavior.
- Adding a separate onboarding wizard.
- Asking for microphone permission earlier than the current flow does.
- Hiding genuine model-loading failures.
- Changing audio recording format or transcription behavior.
- Building App Store/TestFlight automation.

## Decisions

- Add a `RecordingScreenSetup` presentation enum or constants near the existing recording-screen copy. This follows the current view-adjacent testing pattern used for orientation, recovery, suggestion, and metadata copy.
- Use title/body/status copy rather than a large explanatory screen. The setup view should be reassuring but not feel like a landing page.
- Keep the progress bar only for `.downloading(progress)`. For `.loading` and `.notLoaded`, show an indeterminate progress indicator with copy that says Sift is preparing speech recognition on device.
- Include a lightweight note such as "First setup can take a little while" so users understand delay without feeling blamed.
- Add a specific transient recording state, such as `preparingToRecord`, to `RecordingState`. `startRecording()` should set it synchronously before awaiting permission/recorder setup. The UI should show "Getting microphone ready..." and disable the mic action while this state is active.
- If `startRecording()` is called while recording startup is already in progress, it should no-op. This makes repeated taps harmless and keeps the state machine deterministic.
- If permission is granted and recorder startup succeeds, transition directly from the transient state to `recording`. If permission is denied or recorder startup fails, transition to the existing recovery/error path.
- Create the Application Support directory before `ModelContainer` initialization in `siftApp.init()`. Keep this narrowly scoped: do not change SwiftData schema, store filename, store location, or migration behavior.

## Risks / Trade-offs

- More copy can feel like clutter if the model loads quickly. Mitigation: only show it during setup states, before the main check-in flow is ready.
- A precise time estimate could become misleading across devices. Mitigation: use "can take a little while" instead of seconds.
- A new transient state touches view model equality and UI switching. Mitigation: add focused state and view model tests.
- Directory preparation may not eliminate every CoreData diagnostic line. Mitigation: keep the fix scoped to creating the expected parent directory and verify persistence still passes.
