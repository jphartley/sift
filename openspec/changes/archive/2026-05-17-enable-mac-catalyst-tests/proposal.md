## Why

Running `xcodebuild test` currently takes ~34 seconds even with the simulator already warm — but the 272 unit tests themselves finish in ~1 second. The other 33 seconds is pure overhead: building and launching the full iOS app before any test can start. Enabling Mac Catalyst lets tests run natively on macOS, eliminating the simulator entirely and cutting total test time to ~5–8 seconds.

## What Changes

- Enable Mac Catalyst on the `sift` app target (`SUPPORTS_MACCATALYST = YES`)
- Enable Mac Catalyst on the `siftTests` target
- Add `#if os(iOS)` / `#if !targetEnvironment(macCatalyst)` guards around the two iOS-only call sites in `RecordingScreen.swift` (`UIApplication.openSettingsURLString` and `UIApplication.shared.open()`)
- Add a macOS test command to `AGENTS.md` and `docs/testing.md`

## Capabilities

### New Capabilities

- `mac-catalyst-test-execution`: Run the unit test suite natively on macOS via `xcodebuild test -destination 'platform=macOS,variant=Mac Catalyst'`, with no simulator required.

### Modified Capabilities

- `automated-tests`: The test invocation gains a macOS/Catalyst destination option alongside the existing iOS Simulator destination.

## Impact

- **RecordingScreen.swift**: Two call sites need platform guards; the settings-navigation behaviour is silently skipped on macOS (no `Settings.app` equivalent in Catalyst).
- **project.pbxproj**: `SUPPORTS_MACCATALYST` toggled to `YES` for both `sift` and `siftTests` targets.
- **Dependencies**: WhisperKit (macOS 13+), GoogleGenerativeAI (explicit `.macCatalyst(.v13)`), and Yams (unrestricted) all support macOS — no dependency changes needed.
- **Test suite**: No test file changes required; all test imports are already Catalyst-compatible.
- **docs/testing.md** and **AGENTS.md**: Updated with the new fast test invocation.
