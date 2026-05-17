## 1. DebugMetricsScreen UI

- [x] 1.1 Add `@State private var showResetOnboardingConfirmation = false` to `DebugMetricsScreen`
- [x] 1.2 Add an "Onboarding" `Section` to `summaryList` containing a "Reset onboarding" `Button` (role: `.destructive`) that sets `showResetOnboardingConfirmation = true`
- [x] 1.3 Add a `confirmationDialog` modifier to the screen for "Reset onboarding?" with a destructive "Reset" action and a "Cancel" action

## 2. Reset Logic

- [x] 2.1 Implement `resetOnboarding()` private method in `DebugMetricsScreen` that fetches all `UserPracticeProfile` records via `modelContext` and deletes each one, then calls `try? modelContext.save()`
- [x] 2.2 Wire the destructive "Reset" dialog action to call `resetOnboarding()`

## 3. Tests

- [x] 3.1 Add `DebugMetricsResetTests.swift` in `siftTests/Views/` covering: reset deletes all profiles and leaves other entities untouched; cancel leaves profiles unchanged
- [x] 3.2 Add a test verifying `IntakeGate.shouldShowIntake(profiles:)` returns `true` after profiles are emptied (the gate logic is already tested but confirm the empty-array case is covered)

## 4. Verification

- [ ] 4.1 Build and run on iPhone 17 Pro simulator; open Debug tab, tap "Reset onboarding", confirm, verify the app transitions to the intake screen
- [ ] 4.2 Repeat and tap Cancel; verify no transition occurs and no profiles are deleted
- [x] 4.3 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -skip-testing:siftUITests` and confirm all tests pass
