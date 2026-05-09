## Why

The ready state of the Record tab currently gives users a clear mechanical action but little emotional or practical orientation. For an internal TestFlight beta with trusted users who may share vulnerable check-ins, the first screen should help them understand what to say, how long to speak, what Sift will do next, and that there is no right or wrong way to begin.

## What Changes

- Add first-screen orientation copy to the ready recording state.
- Explain that users can speak for about a minute about what feels most alive right now.
- Reassure users that there is no right or wrong way to check in.
- Explain the core loop: Sift transcribes on device, reflects back what it heard, and suggests practices.
- Add starter prompts to reduce blank-screen uncertainty.
- Preserve the primary microphone action as the main call to action.
- Add or update tests for the new user-facing orientation behavior.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `voice-check-in`: The ready recording state shall orient users before their first or next voice check-in.
- `automated-tests`: Automated coverage shall verify the ready recording screen exposes the orientation copy.

## Impact

- Affected code: `sift/Views/RecordingScreen.swift`
- Affected tests: UI or view-adjacent tests under `siftTests/` or `siftUITests/`
- No persistence, service, dependency, API, or data model changes are expected.
