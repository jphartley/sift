## 1. Fix iOS-only call sites in RecordingScreen.swift

- [x] 1.1 Wrap `UIApplication.openSettingsURLString` usage with `#if !targetEnvironment(macCatalyst)` so it compiles on macOS
- [x] 1.2 Wrap `UIApplication.shared.open(url)` call with the same guard (no-op on macOS)
- [x] 1.3 Verify the existing `settingsActionTargetsAppSettingsPage` test still passes on iOS

## 2. Enable Mac Catalyst in the Xcode project

- [x] 2.1 Set `SUPPORTS_MACCATALYST = YES` for the `sift` app target in `project.pbxproj`
- [x] 2.2 Set `SUPPORTS_MACCATALYST = YES` for the `siftTests` target in `project.pbxproj`
- [x] 2.3 Confirm build succeeds: `xcodebuild build -scheme sift -destination 'platform=macOS,variant=Mac Catalyst'`

## 3. Verify tests pass on macOS

- [x] 3.1 Run `xcodebuild test -scheme sift -destination 'platform=macOS,variant=Mac Catalyst' -only-testing:siftTests -skip-testing:siftTests/GeminiBenchmark -enableCodeCoverage NO` and confirm all tests pass (note: `-enableCodeCoverage NO` required — yyjson, a WhisperKit transitive C dependency, has a profiling-runtime link failure on Catalyst with coverage enabled)
- [x] 3.2 Confirm test count on macOS matches the iOS Simulator count (271 on macOS vs 272 on iOS — expected: `settingsActionTargetsAppSettingsPage` is correctly guarded iOS-only)
- [x] 3.3 Run `xcodebuild test -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:siftTests -skip-testing:siftTests/GeminiBenchmark` and confirm nothing regressed

## 4. Update documentation

- [x] 4.1 Add the Catalyst test command to `AGENTS.md` Build & run section as the fast-feedback option
- [x] 4.2 In `docs/testing.md` Running tests section: add the macOS/Catalyst command block and label it as the fast-feedback path (no simulator); label the existing iOS Simulator command as the full-fidelity path
- [x] 4.3 In `docs/testing.md` test pyramid: update the INT/API and UNIT/API timing rows to reflect Catalyst run times (~5–8s total vs ~34s on simulator)
- [x] 4.4 In `docs/testing.md` "What's not tested" section: note that `AudioRecorderServiceTests` now run on macOS via Catalyst (AVFoundation is available) but without a real microphone, so live recording is still untested
