## 1. Ready-Screen Orientation

- [x] 1.1 Add the settled first-screen orientation copy to the ready recording state in `RecordingScreen`.
- [x] 1.2 Keep the microphone recording action visually primary and verify tapping it still starts recording.
- [x] 1.3 Ensure the ready screen remains usable on smaller devices and when a last transcript is present.
- [x] 1.4 Remove the persistent "Check In" navigation title from the recording flow.
- [x] 1.5 Replace the full first-time orientation with simpler returning guidance when a previous transcript is visible.

## 2. Test Coverage

- [x] 2.1 Add or update automated tests that verify the ready-screen orientation heading, reassurance copy, core loop explanation, and starter prompts.
- [x] 2.2 Run focused tests for the changed coverage.
- [x] 2.3 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` before completion.
- [x] 2.4 Add or update automated tests for the simpler returning guidance.

## 3. Cleanup

- [x] 3.1 Perform a scoped cleanup pass for the changed UI/tests, removing unused imports or unnecessary abstraction.
- [x] 3.2 Check whether `AGENTS.md` needs updates; leave it unchanged if architecture, dependencies, commands, and workflows are unchanged.
