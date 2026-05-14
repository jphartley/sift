# Test System Improvement

Prioritized checklist for improving test coverage and infrastructure. See [tech-debt.md](tech-debt.md) for broader code health context.

**Current state:** 156 tests, 0.82x test/production LOC ratio, Apple Swift Testing framework. Service layer is well-covered with protocol-based DI and hand-rolled fakes. Main gaps are View behavioral coverage, a couple of boundary cases in routing/resolution logic, and a few longer-horizon items.

---

## Tier 1 — High value, low effort

- [x] **Add GitHub Actions CI** — `xcodebuild test` on every PR. One YAML file; turns all existing tests into regression guards and unblocks mutation testing.
- [x] **Add `CheckInRecoveryPresentationTests` edge cases** — added structural invariant tests: secondary label/action must always be paired, and each `Kind` maps to the correct primary action.
- [x] **Extract and test `ReflectionView` logic** — extracted `HelpfulnessOption`, `wasHelpfulForSave`, and `notesForSave` into `ReflectionViewModel`. Added 8 unit tests including the subtle `.aLittle → nil` mapping.
- [x] **Add `HistoryScreen` row regression test for `practiceName` display** — extracted `HistoryRowPresentation.pillText(for:)` and added two tests in [`HistoryRowPresentationTests.swift`](../siftTests/Views/HistoryRowPresentationTests.swift) pinning that the pill renders the human name, not the slug. Pairs with the bug fix in `HistoryScreen.sessionRow`.
- [x] **Add confidence-threshold boundary tests for `GeminiRecommendationRouter`** — added `confidence0_69EscalatesToPro`, `confidence0_70DoesNotEscalate`, `confidence0_71DoesNotEscalate` in [`GeminiRecommendationRouterTests.swift`](../siftTests/Services/GeminiRecommendationRouterTests.swift) to pin the `>= 0.7` boundary.
- [x] **Add `resolvePractices` silent-drop test in `RecordingViewModel`** — added `partiallyResolvablePracticesDropsBogusIds` in [`RecordingViewModelTests.swift`](../siftTests/ViewModels/RecordingViewModelTests.swift): one valid + one bogus ID → exactly one `Practice` in `.suggesting`. The all-bogus case (`noResolvablePracticesShowsEmptySuggestionsRecovery`) was already covered.

## Tier 2 — Medium value, medium effort

- [x] **Fix `GeminiLoggingTests` approach** — replaced source-file static analysis with behavioral async tests. `GeminiService` and `GeminiRecommendationRouter` now accept an injected logger closure; tests capture output and assert sensitive content never appears.
- [ ] **Add `SuggestionView` interaction test** — verify "tapping card body does X, tapping Try This button does Y" before fixing the nested button semantics, so the fix has a regression guard. Mentioned in [tech-debt.md](tech-debt.md).
- [x] **Expand `HistoryViewModel` deletion tests** — added: delete last session, delete all sessions, and successful deletion clears a previous error.
- [x] **Extract and test `HistoryScreen.grouped` week-bucketing** — extracted `HistoryGrouping.group(sessions:now:calendar:)` into [`HistoryGrouping.swift`](../sift/Views/HistoryGrouping.swift); `HistoryScreen.grouped` delegates to it. Added 12 tests in [`HistoryGroupingTests.swift`](../siftTests/Views/HistoryGroupingTests.swift) covering: empty input, all three buckets, all four week boundaries (exact start of this week, just before, exact start of last week, just before), year-crossing week, DST spring-forward (calendar arithmetic vs naïve `-7*24*3600`), and Sunday-start vs Monday-start `firstWeekday`.
- [x] **Add prompt-injection resistance test for `GeminiPromptBuilder`** — added `transcriptFakeSectionHeadersDoNotCorruptHistorySection` in [`GeminiPromptBuilderTests.swift`](../siftTests/Services/GeminiPromptBuilderTests.swift): transcript with embedded `## User History` headers cannot pollute the real history section — "sleep-meditation" appears only in Current Check-In, not in User History.
- [x] **Add `PracticeAttempt` denormalization test** — added `practiceNameMatchesSourcePracticeName` in [`PracticeAttemptTests.swift`](../siftTests/Models/PracticeAttemptTests.swift): verifies `attempt.practiceName == practice.name` and `!= practice.id`, pinning the contract `HistoryScreen` relies on.

## Tier 3 — Right direction, not urgent

- [ ] **Mutation testing with `muter`** — target `GeminiRecommendationRouter` (the `0.7` confidence threshold) and `GeminiRecommendationParser` (silent `compactMap` drops). Line coverage won't catch these. (`selectRecommendationHistory()` was previously listed here but is already well-covered with boundary tests at 5/20/21/30 sessions — see [`SwiftDataTests.swift:157-292`](../siftTests/Models/SwiftDataTests.swift).)
- [ ] **Snapshot tests for Design components** — once the UI stabilizes, one snapshot suite for `SiftComponents` and `CategoryIcon` would catch visual regressions cheaply with minimal maintenance.
- [ ] **Integration test for the recommendation pipeline** — one happy-path test: Recording → Transcription → Gemini (fake) → SwiftData persistence → history retrieval. Catches wiring errors that unit tests with fakes miss.
- [ ] **Consolidate duplicated test fakes into `siftTests/Fakes/`** — `FakeRequester`, `FakeGeminiModelRequester`, and `TrackingGeminiRequester` are three near-identical implementations of `GeminiModelRequesting` across three files; similarly `FakeSessionStore` / `FakeHistorySessionStore`. Not actively painful, but worth doing before the Tier 1/2 additions above so they don't add a fourth fake.

---

## Reference: coverage by layer

| Layer | Coverage | Biggest gap |
|---|---|---|
| Services | Strong | None significant |
| Models / SwiftData | Strong | None significant |
| ViewModels | Good | No integration tests |
| Views | Weak | `SuggestionView` interaction test still open |
| CI / Tooling | Good | No mutation testing |
