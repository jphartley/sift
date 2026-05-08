## Why

`RecordingViewModel` starts asynchronous recording-meter polling and check-in analysis work, but production code does not own those task handles. That makes repeated setup, view disappearance, and rapid user actions more likely to leave stale work running or updating state after the active flow has moved on.

## What Changes

- Store task handles for recording meter polling and analysis work owned by the check-in flow.
- Cancel existing task handles before starting replacement polling or analysis work.
- Add a teardown path that the recording UI can call when the view disappears.
- Ensure cancellation prevents stale async work from publishing outdated state after a newer flow has started or the screen has disappeared.
- Add behavior-focused tests for task replacement and teardown cancellation.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `voice-check-in`: Add lifecycle requirements for canceling and replacing in-flight recording meter and analysis tasks.
- `automated-tests`: Add tests that cover async task cancellation, replacement, and teardown behavior in the check-in flow.

## Impact

- Affected code: `RecordingViewModel`, `RecordingScreen`, and related unit tests.
- Public API impact: likely a small teardown method on `RecordingViewModel` for view disappearance.
- Dependencies: no new package dependencies expected.
- Persistence and recommendation contracts remain unchanged.
