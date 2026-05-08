## 1. Practice Schema Migration

- [x] 1.1 Update `Practice` decoding to require `labels`, `best_for`, `summary`, `steps`, `why_it_helps`, `intensity`, and `avoid_when`.
- [x] 1.2 Remove app usage of legacy `description` and use `summary` for compact user-facing practice text.
- [x] 1.3 Update test fixtures to use the richer practice schema.

## 2. Bundled Library Content

- [x] 2.1 Replace the initial test YAML entries with enriched Breathwork practices.
- [x] 2.2 Add enriched Meditation practices.
- [x] 2.3 Add enriched Grounding practices.
- [x] 2.4 Add enriched Movement practices.
- [x] 2.5 Preserve the planning document with selected categories, schema decisions, and the next open category.

## 3. Recommendation and UI Integration

- [x] 3.1 Include enriched practice metadata in the Gemini recommendation prompt.
- [x] 3.2 Keep full practice steps out of the Gemini prompt until there is a dedicated guided-practice use case.
- [x] 3.3 Ensure suggestion cards display `summary` in collapsed and expanded states.
- [x] 3.4 Ensure selected practice reflection context uses `summary`.

## 4. Verification and Cleanup

- [x] 4.1 Add or update practice library tests for non-empty richer metadata.
- [x] 4.2 Update affected prompt builder and recording view model tests.
- [x] 4.3 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 4.4 Complete a scoped cleanup pass and update `AGENTS.md` if the project guidance has drifted.
