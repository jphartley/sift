## 1. View Model Task Ownership

- [x] 1.1 Add private task handles to `RecordingViewModel` for meter polling and analysis work.
- [x] 1.2 Cancel and replace the meter polling task when recording starts.
- [x] 1.3 Cancel meter polling when recording stops or recording startup fails.
- [x] 1.4 Cancel and replace the analysis task when `stopRecording()` starts transcription/recommendation work.
- [x] 1.5 Cancel and replace the analysis task when `retryAnalysis()` starts recommendation work.

## 2. Cancellation Semantics

- [x] 2.1 Check for cancellation after transcription completes and before creating or updating `pendingSession`.
- [x] 2.2 Check for cancellation after recommendation/history work completes and before applying suggestion state.
- [x] 2.3 Treat intentional cancellation as silent teardown/replacement rather than a user-visible analysis error.
- [x] 2.4 Clear completed task handles when owned async work finishes.

## 3. UI Lifecycle

- [x] 3.1 Add a teardown method to `RecordingViewModel` that cancels owned tasks and stops active recording.
- [x] 3.2 Call the teardown method from `RecordingScreen` when the screen disappears.
- [x] 3.3 Preserve existing setup, recording, stop, retry, save, and skip behavior for normal successful flows.

## 4. Tests

- [x] 4.1 Add or update fake transcription/recommendation clients so tests can control delayed async completion.
- [x] 4.2 Add a test proving meter polling is canceled after recording stops.
- [x] 4.3 Add a test proving retry analysis cancels or ignores an earlier in-flight analysis result.
- [x] 4.4 Add a test proving teardown during analysis prevents stale suggestions or cancellation-only errors.
- [x] 4.5 Add a test proving teardown during recording stops the recorder and cancels meter polling.
- [x] 4.6 Run focused `RecordingViewModelTests`.

## 5. Completion

- [x] 5.1 Run the full `xcodebuild test` suite.
- [x] 5.2 Perform the scoped cleanup pass.
- [x] 5.3 Check whether `AGENTS.md` needs architecture or workflow updates.
- [x] 5.4 Validate the OpenSpec change.
