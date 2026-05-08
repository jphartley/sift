## Context

`RecordingViewModel` currently creates unowned `Task` instances for recording-meter polling, stop-recording transcription/recommendation analysis, and retry analysis. Tests can await the returned stop/retry task, but production has no way to cancel these tasks when a replacement starts or when `RecordingScreen` disappears.

The app uses Swift 6 default `MainActor` isolation and `@Observable` view models. The implementation should keep state ownership in `RecordingViewModel`, preserve existing test ergonomics, and avoid adding dependencies.

## Goals / Non-Goals

**Goals:**
- Make `RecordingViewModel` own task handles for meter polling and analysis.
- Cancel stale meter polling before starting a new recording and when recording stops.
- Cancel stale analysis before starting a new stop-recording or retry-analysis task.
- Add a teardown method that `RecordingScreen` calls on disappearance.
- Guard async continuations so canceled work does not publish stale suggestions or errors.
- Cover cancellation behavior with deterministic unit tests.

**Non-Goals:**
- Redesign the recording state machine.
- Change transcription, recommendation, or SwiftData persistence contracts.
- Add a broad lifecycle framework or dependency.
- Introduce background execution for check-ins after the screen disappears.

## Decisions

### View model owns task handles

Add private optional task properties such as `meterPollingTask` and `analysisTask` to `RecordingViewModel`.

Alternative considered: keep returning tasks to callers without storing them. That preserves test behavior but does not solve production cancellation, so it does not address the debt.

### Keep returned tasks for tests

`stopRecording()` and `retryAnalysis()` should continue returning the analysis task while also storing it internally. Existing tests already use this shape, and it gives new tests a deterministic way to await task completion or cancellation.

Alternative considered: remove return values and expose separate synchronization hooks. That would add test-only surface area without improving app behavior.

### Cancel before replacement

Before starting new meter polling or analysis work, cancel the existing task handle and replace it with the new task. Stopping recording should also cancel meter polling because the loop is no longer useful once the recorder stops.

Alternative considered: rely on `audioRecorder.isRecording` to end polling naturally. That handles the happy path, but it does not cover repeated starts, teardown, or delayed loop wake-ups cleanly.

### Add explicit teardown

Add a small `tearDown()` or similarly named method on `RecordingViewModel` that cancels owned tasks and stops active recording. `RecordingScreen` should call it from `.onDisappear`.

Alternative considered: depend on view/model deinitialization. `@State` lifetime and tab navigation make deinit timing less explicit than a view lifecycle hook.

### Check cancellation after awaits

After transcription, recommendation, and history awaits/throws points, the analysis task should check whether it was canceled before mutating user-visible state. Cancellation should be treated as intentional teardown/replacement, not as an error alert.

Alternative considered: only cancel task handles and rely on cooperative cancellation from child operations. Some fake or SDK-backed operations may finish after cancellation, so explicit checks are safer.

## Risks / Trade-offs

- Canceled SDK work may continue internally until its await returns → state checks prevent stale UI updates, but they may not stop lower-level network or model work immediately.
- Teardown while recording may discard an unsaved in-flight recording → this matches leaving the screen during an unfinished check-in and avoids orphaned work.
- Tests involving cancellation can become timing-sensitive → use deterministic fakes with continuations or controllable delays rather than fixed sleeps wherever practical.
