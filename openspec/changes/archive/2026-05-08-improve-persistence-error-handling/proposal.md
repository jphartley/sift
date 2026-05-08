## Why

History deletion currently performs direct SwiftData mutation in `HistoryScreen` and swallows save failures with `try?`. That makes a failed delete look successful to the user and leaves the history flow less testable than the check-in persistence path.

## What Changes

- Route history deletion through a persistence boundary instead of direct view-level SwiftData save calls.
- Surface delete/save failures in the history UI with a user-visible error path.
- Add focused tests for successful deletion, cascade behavior preservation, and failed delete/save behavior.
- Keep the check-in save behavior unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `practice-loop`: History deletion must surface persistence failures instead of silently swallowing them.
- `check-in-service-abstractions`: The persistence abstraction must cover history deletion in addition to check-in save/history reads.
- `automated-tests`: Tests must cover the new history deletion persistence success and failure paths.

## Impact

- Affected code: `HistoryScreen`, `SwiftDataSessionStore` or a small dedicated history store, and related test fakes.
- Affected tests: likely new service/store tests and/or focused view-model/store tests around delete failure behavior.
- No new dependencies, build commands, or data model schema changes are expected.
