## Context

The `siftTests` unit test target is currently a hosted test bundle (`TEST_HOST` points to `sift.app`). This forces xcodebuild to build the full app, install it into an iOS simulator, launch it, and inject the test bundle into the running process — even though the tests themselves have no dependency on the app being alive. The 272 unit tests finish in ~1 second; the simulator scaffolding costs ~33 seconds.

Mac Catalyst (introduced in macOS 10.15) lets iOS/iPadOS apps compile and run natively on macOS. With Catalyst enabled, `xcodebuild test` can target `platform=macOS,variant=Mac Catalyst`, which runs the test binary directly in macOS — no simulator, no app install.

All three SPM dependencies support macOS: WhisperKit declares `.macOS(.v13)`, GoogleGenerativeAI declares `.macCatalyst(.v13)`, and Yams has no platform restriction. All test file imports (`Testing`, `Foundation`, `SwiftData`, `AVFoundation`) are Catalyst-compatible with no changes.

The only blocker is two call sites in `RecordingScreen.swift` that use iOS-only UIKit APIs to open the system Settings app.

## Goals / Non-Goals

**Goals:**
- Enable `xcodebuild test -destination 'platform=macOS,variant=Mac Catalyst'` to run the full unit test suite without a simulator
- Keep the iOS Simulator destination working (existing dev/CI workflow unchanged)
- Fix the two iOS-only call sites with the minimum platform guard needed to compile on macOS

**Non-Goals:**
- Shipping or distributing a Mac Catalyst build of the sift app to users
- Full Mac Catalyst UI polish (settings navigation simply does nothing on macOS — acceptable since it's a mic permission recovery flow that doesn't apply on macOS anyway)
- Enabling `siftUITests` on macOS (XCUIApplication-based UI tests remain iOS-only)

## Decisions

**Enable Catalyst on the app target, not just the test target**

The test target uses `@testable import sift`, so the `sift` module must also compile for macOS. Enabling Catalyst on `siftTests` alone is insufficient — `sift` itself must build for `macOS,variant=Mac Catalyst` too.

*Alternative considered:* Extract shared logic into a separate framework that targets macOS. This would avoid touching the app target at all but is far more invasive — it requires a new Xcode target, moving files, and updating imports everywhere. Not justified for this change.

**Platform-guard the Settings call sites with `#if canImport(UIKit) && !targetEnvironment(macCatalyst)`**

`UIApplication.openSettingsURLString` doesn't exist on macCatalyst. The guard wraps only the two affected lines; the surrounding `RecordingScreenSettings` type and `settingsActionTargetsAppSettingsPage` test remain intact.

*Alternative considered:* Replace with `NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:...")!)` on macOS. Rejected: there is no meaningful Settings destination to send macOS users to for microphone permissions in this context (the recovery flow is iOS-specific). Silently no-op is correct behavior.

**Keep `TEST_HOST` as-is**

Removing `TEST_HOST` would speed up iOS simulator runs slightly (~5–8s) but adds complexity and is not needed once the macOS destination is available. One improvement at a time.

## Risks / Trade-offs

- **WhisperKit Catalyst path untested by upstream**: WhisperKit declares `.macOS(.v13)` but not `.macCatalyst`. The model loading path (unused in tests) may have issues at runtime. → Mitigation: tests don't load WhisperKit models; the risk is deferred until a Mac app distribution decision is made.
- **iOS 26.4 deployment target**: The project targets a beta SDK. Catalyst on beta SDKs occasionally has build toolchain quirks. → Mitigation: if the Catalyst build fails for toolchain reasons, the iOS Simulator destination remains the fallback and this change is reverted cleanly (it's isolated to build settings + two guarded lines).
- **`AVAudioSession` on macOS**: `AudioRecorderServiceTests` uses `AVFoundation`. On macOS/Catalyst, `AVAudioSession` exists but some category/mode combinations behave differently. → Mitigation: the tests mock the recorder at the protocol level; no live `AVAudioSession` calls are made in tests.

## Migration Plan

1. Add platform guards to `RecordingScreen.swift` (isolated, no behaviour change on iOS).
2. Flip `SUPPORTS_MACCATALYST = YES` in `project.pbxproj` for both targets.
3. Verify `xcodebuild build` succeeds for the macOS destination.
4. Verify `xcodebuild test -destination 'platform=macOS,variant=Mac Catalyst'` passes all 272 tests.
5. Update `AGENTS.md` and `docs/testing.md` with the new fast invocation.

Rollback: revert the two build setting changes and the platform guard. No data migration, no schema change.
