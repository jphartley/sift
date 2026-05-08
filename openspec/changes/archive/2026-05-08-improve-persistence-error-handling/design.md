## Context

The check-in flow already uses `SessionStore` to save completed sessions and retrieve recommendation history, allowing `RecordingViewModel` to surface save failures. The history flow still deletes sessions directly from `HistoryScreen` with `modelContext.delete(...)` followed by `try? modelContext.save()`, so failed persistence is silent and hard to test.

SwiftData remains the backing store, and the app does not need a schema migration for this change. The core design pressure is to keep view code simple while making deletion behavior observable and testable.

## Goals / Non-Goals

**Goals:**

- Route history deletion through a narrow persistence abstraction.
- Preserve existing swipe-to-delete behavior and cascade deletion of attempts.
- Surface delete/save failures in the history UI.
- Add focused tests for success and failure behavior without relying on live UI automation.

**Non-Goals:**

- Redesign the history screen or session detail UI.
- Change the SwiftData model schema.
- Add undo, confirmation dialogs, or bulk history management.
- Change check-in session save semantics.

## Decisions

### Extend the existing session persistence boundary

Add deletion behavior to the existing session persistence abstraction rather than introducing a separate history store immediately. The current `SessionStore` already owns session-oriented SwiftData behavior: recommendation history reads and check-in saves. Deleting a session is part of the same aggregate lifecycle, and keeping it in one store avoids parallel wrappers around the same `ModelContext`.

Alternative considered: create a dedicated `HistoryStore`. That would keep read/write surfaces separated by UI, but it adds another abstraction before the app has enough history-specific behavior to justify it.

### Keep deletion synchronous and throwing

Expose deletion as a throwing method that deletes selected `Session` instances and calls `save()`. SwiftData operations are currently used synchronously on the main actor, matching the app's default actor isolation and the current `SessionStore.save(_:)` API.

Alternative considered: make deletion async. That may be useful if persistence moves off the main actor later, but today it would add ceremony without changing the underlying SwiftData behavior.

### Add a small testable history state owner if direct view testing is awkward

If `HistoryScreen` cannot be tested cleanly as a SwiftUI view, introduce a small history-focused model/controller that owns deletion state and depends on the store. The view can remain a thin renderer for sessions, delete action, and error alert.

Alternative considered: keep all logic in `HistoryScreen` and test the store only. That would verify persistence but leave the user-visible error path less covered.

## Risks / Trade-offs

- Store protocol growth could become too broad -> Keep the new method limited to session deletion and revisit a dedicated history store only when history behavior expands.
- SwiftData rollback behavior after failed save can be subtle -> Add a failure-path test around the injectable deletion owner/fake store, and preserve existing cascade tests for real SwiftData behavior.
- A failed delete may leave the SwiftData context in an uncertain in-memory state -> Surface the error immediately and avoid presenting the operation as successful; consider explicit rollback only if implementation or tests show stale UI state.
