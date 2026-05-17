## Why

Iterating on the onboarding flow requires repeatedly re-running intake from a clean slate, which currently means manually deleting and reinstalling the app. A single debug action that resets all intake data would cut that cycle time significantly.

## What Changes

- Add a "Reset onboarding" button to `DebugMetricsScreen`, visible only in Debug builds
- Tapping it confirms then deletes every `UserPracticeProfile` record from SwiftData
- After deletion, `IntakeGate.shouldShowIntake` returns `true` (profiles empty), so `ContentView` switches back to `IntakeScreen` automatically via the reactive `@Query`
- No other SwiftData entities (`Session`, `PracticeAttempt`, `MetricEvent`) are affected

## Capabilities

### New Capabilities

- `debug-reset-onboarding`: A destructive debug action in the debug metrics screen that deletes all persisted `UserPracticeProfile` records, causing the app to re-display the first-time intake flow automatically.

### Modified Capabilities

- `debug-metrics-screen`: Adds a new "Reset onboarding" action section to the existing debug metrics screen.

## Impact

- `sift/Views/DebugMetricsScreen.swift` — new UI section and action
- `sift/Models/UserPracticeProfile.swift` — read-only; deletion uses existing SwiftData patterns
- `siftTests/Views/` — new test coverage for the reset action and its guard
