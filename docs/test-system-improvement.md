# Test System Improvement

Prioritized checklist for improving test coverage and infrastructure. See [tech-debt.md](tech-debt.md) for broader code health context.

**Current state:** 156 tests, 0.82x test/production LOC ratio, Apple Swift Testing framework. Service layer is well-covered with protocol-based DI and hand-rolled fakes. Main gaps are CI/tooling, View behavioral coverage, and a few ViewModel edge cases.

---

## Tier 1 — High value, low effort

- [x] **Add GitHub Actions CI** — `xcodebuild test` on every PR. One YAML file; turns all existing tests into regression guards and unblocks mutation testing.
- [ ] **Add `CheckInRecoveryPresentationTests` edge cases** — re-trigger while already showing, concurrent state changes, recovery with no pending state. Currently only the happy-path `showRecovery` → `dismiss` flow is covered.
- [ ] **Extract and test `ReflectionView` logic** — if the selection/callback logic is non-trivial, move it to a ViewModel and test the ViewModel. Don't test SwiftUI views directly; test the logic that drives them.

## Tier 2 — Medium value, medium effort

- [ ] **Fix `GeminiLoggingTests` approach** — the source-file static analysis pattern is fragile: it breaks on cosmetic print format changes and misses logging via `os.log`/`Logger`/`NSLog`. Replace with a testable `Logger` protocol injected into services, or a SwiftLint rule.
- [ ] **Add `SuggestionView` interaction test** — verify "tapping card body does X, tapping Try This button does Y" before fixing the nested button semantics, so the fix has a regression guard. Mentioned in [tech-debt.md](tech-debt.md).
- [ ] **Expand `HistoryViewModel` deletion tests** — add explicit coverage for: deleting the last session, deletion while in edit mode, multi-select deletion.

## Tier 3 — Right direction, not urgent

- [ ] **Mutation testing with `muter`** — target `GeminiRecommendationRouter` (the `0.7` confidence threshold), `GeminiRecommendationParser` (silent `compactMap` drops), and `selectRecommendationHistory()` boundary conditions. Line coverage won't catch these.
- [ ] **Snapshot tests for Design components** — once the UI stabilizes, one snapshot suite for `SiftComponents` and `CategoryIcon` would catch visual regressions cheaply with minimal maintenance.
- [ ] **Integration test for the recommendation pipeline** — one happy-path test: Recording → Transcription → Gemini (fake) → SwiftData persistence → history retrieval. Catches wiring errors that unit tests with fakes miss.

---

## Reference: coverage by layer

| Layer | Coverage | Biggest gap |
|---|---|---|
| Services | Strong | GeminiLogging pattern is fragile |
| Models / SwiftData | Strong | None significant |
| ViewModels | Good | CheckInRecovery shallow; no integration |
| Views | Weak | Behavioral logic untested; constants only |
| CI / Tooling | Missing | No GitHub Actions; no mutation testing |
