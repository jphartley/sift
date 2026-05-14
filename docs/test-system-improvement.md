# Test System Improvement

Prioritized checklist for improving test coverage and infrastructure. See [tech-debt.md](tech-debt.md) for broader code health context.

**Current state:** 156 tests, 0.82x test/production LOC ratio, Apple Swift Testing framework. Service layer is well-covered with protocol-based DI and hand-rolled fakes. Main gaps are CI/tooling, View behavioral coverage, and a few ViewModel edge cases.

---

## Tier 1 — High value, low effort

- [x] **Add GitHub Actions CI** — `xcodebuild test` on every PR. One YAML file; turns all existing tests into regression guards and unblocks mutation testing.
- [x] **Add `CheckInRecoveryPresentationTests` edge cases** — added structural invariant tests: secondary label/action must always be paired, and each `Kind` maps to the correct primary action.
- [x] **Extract and test `ReflectionView` logic** — extracted `HelpfulnessOption`, `wasHelpfulForSave`, and `notesForSave` into `ReflectionViewModel`. Added 8 unit tests including the subtle `.aLittle → nil` mapping.

## Tier 2 — Medium value, medium effort

- [x] **Fix `GeminiLoggingTests` approach** — replaced source-file static analysis with behavioral async tests. `GeminiService` and `GeminiRecommendationRouter` now accept an injected logger closure; tests capture output and assert sensitive content never appears.
- [ ] **Add `SuggestionView` interaction test** — verify "tapping card body does X, tapping Try This button does Y" before fixing the nested button semantics, so the fix has a regression guard. Mentioned in [tech-debt.md](tech-debt.md).
- [x] **Expand `HistoryViewModel` deletion tests** — added: delete last session, delete all sessions, and successful deletion clears a previous error.

## Tier 3 — Right direction, not urgent

- [ ] **Mutation testing with `muter`** — target `GeminiRecommendationRouter` (the `0.7` confidence threshold), `GeminiRecommendationParser` (silent `compactMap` drops), and `selectRecommendationHistory()` boundary conditions. Line coverage won't catch these.
- [ ] **Snapshot tests for Design components** — once the UI stabilizes, one snapshot suite for `SiftComponents` and `CategoryIcon` would catch visual regressions cheaply with minimal maintenance.
- [ ] **Integration test for the recommendation pipeline** — one happy-path test: Recording → Transcription → Gemini (fake) → SwiftData persistence → history retrieval. Catches wiring errors that unit tests with fakes miss.

---

## Reference: coverage by layer

| Layer | Coverage | Biggest gap |
|---|---|---|
| Services | Strong | None significant |
| Models / SwiftData | Strong | None significant |
| ViewModels | Good | No integration tests |
| Views | Weak | Behavioral logic untested; constants only |
| CI / Tooling | Good | No mutation testing |
