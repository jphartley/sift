## Context

The recording screen already owns the voice check-in lifecycle through `RecordingViewModel`. The current implementation starts recording, polls meter updates, and tears down in-flight work when the view disappears, but it does not manage the system idle timer. That leaves the iPhone free to sleep while the user is still speaking.

## Goals / Non-Goals

**Goals:**
- Prevent the screen from dimming or sleeping while an active voice recording is in progress.
- Restore normal idle behavior immediately after recording ends or the recording UI is dismissed.
- Keep the behavior easy to test without coupling the view model directly to UIKit globals.

**Non-Goals:**
- Do not keep the screen awake during transcription, analysis, or suggestion display.
- Do not change audio recording, transcription, or recommendation behavior.
- Do not add background recording or background execution support.

## Decisions

1. Manage the wake lock at the recording lifecycle boundary rather than by polling elapsed time.
   - Rationale: the need is tied to state, not duration. Recording is the only state that needs the screen held awake.
   - Alternative considered: start a timer after 30 seconds. Rejected because the failure mode begins at the start of recording, and a timer adds unnecessary complexity.

2. Centralize idle-timer control behind a small abstraction instead of calling UIKit directly from the view body.
   - Rationale: a dedicated controller or protocol makes the behavior testable and keeps UIKit details out of most of the flow.
   - Alternative considered: toggle `UIApplication.shared.isIdleTimerDisabled` directly in `RecordingScreen`. Rejected because it is harder to verify in unit tests and easier to miss a cleanup path.

3. Enable the wake lock only after recorder startup succeeds.
   - Rationale: permission prompts and startup failures should not leave the app in a state that thinks recording is active when it is not.
   - Alternative considered: disable the idle timer as soon as the user taps record. Rejected because that widens the locked-awake window unnecessarily.

4. Release the wake lock on every exit path from active recording.
   - Rationale: the most likely regression is leaving the screen awake after a failed stop, teardown, or interruption.
   - Alternative considered: rely only on the normal stop button path. Rejected because view dismissal and error paths also need cleanup.

## Risks / Trade-offs

- [Risk] The idle timer could remain disabled if a cleanup path is missed. → Mitigation: centralize enable/disable calls and cover start, stop, and teardown paths in tests.
- [Risk] The screen could stay awake longer than needed if recording transitions are not wired precisely. → Mitigation: only enable after `audioRecorder.startRecording()` succeeds and disable on every non-recording exit path.
- [Risk] The change might be platform-specific. → Mitigation: use a no-op or guarded implementation on Catalyst and any non-iPhone target where the wake lock is not meaningful.

## Migration Plan

1. Add the idle-timer abstraction and production implementation.
2. Wire the recording lifecycle to enable wake lock on successful recording start and disable it on stop and teardown.
3. Add unit tests for the lifecycle transitions and cleanup paths.
4. Verify the existing Mac Catalyst test command still passes.

## Open Questions

- None. The intended scope is limited to active voice recording on the check-in screen.
