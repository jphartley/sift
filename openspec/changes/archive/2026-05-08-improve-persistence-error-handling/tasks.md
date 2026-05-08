## 1. Persistence Boundary

- [x] 1.1 Extend the session persistence abstraction with a throwing delete method for one or more `Session` values.
- [x] 1.2 Implement deletion in the SwiftData-backed store by deleting selected sessions and saving the model context.
- [x] 1.3 Preserve existing save and recommendation-history behavior for the check-in flow.

## 2. History Flow

- [x] 2.1 Update `HistoryScreen` or a small history state owner to call the persistence boundary for swipe deletion.
- [x] 2.2 Add user-visible error state for failed history deletion.
- [x] 2.3 Ensure successful deletion keeps the existing session row, empty state, and navigation behavior intact.

## 3. Tests

- [x] 3.1 Add or update fakes for the session persistence boundary to support delete success and delete failure.
- [x] 3.2 Add tests proving history deletion passes selected sessions to the persistence boundary.
- [x] 3.3 Add tests proving delete failures produce a user-visible error state.
- [x] 3.4 Keep or extend in-memory SwiftData coverage proving deleting a session removes associated attempts.

## 4. Documentation and Verification

- [x] 4.1 Check whether `AGENTS.md` needs architecture or test-list updates after implementation.
- [x] 4.2 Run the relevant fast tests during development.
- [x] 4.3 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` before commit.
- [x] 4.4 Do the scoped cleanup pass and remove the completed item from `docs/tech-debt.md`.
