## Context

`ContentView` gates first-time intake by querying `UserPracticeProfile` via `@Query` and calling `IntakeGate.shouldShowIntake(profiles:)`, which returns `true` when the array is empty. Resetting onboarding therefore only requires deleting all `UserPracticeProfile` records — SwiftData's reactive `@Query` propagates the change automatically, flipping the gate and re-rendering `IntakeScreen` without any manual navigation.

The debug panel (`DebugMetricsScreen`) already has a precedent for destructive confirmed actions (the "Clear all metrics" button), providing a clear pattern to follow.

## Goals / Non-Goals

**Goals:**
- Add a single confirmed reset action inside `DebugMetricsScreen` that deletes all `UserPracticeProfile` rows
- Trigger automatic re-display of `IntakeScreen` via the existing reactive gate — no explicit navigation code needed
- Scope to `#if DEBUG` compilation, as the parent view already is

**Non-Goals:**
- Resetting sessions, practice attempts, or metric events
- Any user-facing (non-debug) mechanism to replay onboarding
- Animated or custom transition back to intake

## Decisions

**Where to place the button — a dedicated section in `DebugMetricsScreen`**

Adding a "Onboarding" section (analogous to the existing "Experiments" section structure) keeps the debug screen organized and makes the action visible without cluttering the metrics content. An alternative was a toolbar button, but the existing toolbar slot is used for "Clear all metrics"; a section is less crowded and easier to extend later.

**Confirmation dialog before deleting**

Follows the existing `showClearConfirmation` pattern in `DebugMetricsScreen`. Prevents accidental taps during active testing. Alternatives (no confirmation, swipe-to-delete) were ruled out — the action affects core app state and warrants one extra step.

**No explicit navigation after delete**

Because `ContentView` switches views reactively off `@Query`, the transition happens automatically the moment SwiftData persists the deletion. Explicitly pushing to a view or dismissing tabs would fight the existing architecture.

## Risks / Trade-offs

- [Risk] If other code writes a new `UserPracticeProfile` record synchronously after the delete (e.g., a background task), the gate might immediately flip back. → Mitigation: no such background writer exists today; acceptable risk for a debug-only feature.
- [Risk] The section adds minor visual noise to the debug screen. → Mitigation: section is clearly labeled "Onboarding" and sits below the existing metrics content; it's only visible in Debug builds.
