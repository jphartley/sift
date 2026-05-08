# Technical Debt

Working list of refactor and maintenance areas that are worth addressing after the voice check-in MVP stabilizes. This is intentionally separate from `feature-status.md`: feature status tracks product scope, while this file tracks code health and architecture pressure.

## High Priority

### Bound recommendation history

The recommendation flow still sends all prior session history to Gemini. That is okay for a tiny local dataset, but it will become a cost, latency, and privacy problem as real usage grows.

Suggested direction:
- Add a history policy with a clear max count or token budget.
- Prefer recent sessions plus prior helpful/unhelpful attempts.
- Introduce summaries before full conversational memory work.
- Add tests proving the history passed to the recommender is bounded.

### Improve persistence error handling outside the check-in flow

The check-in flow now uses `SessionStore` and surfaces save failures, but `HistoryScreen` still deletes sessions with direct SwiftData calls and `try? modelContext.save()`.

Suggested direction:
- Decide whether history deletion should use the same `SessionStore` or a dedicated history store.
- Surface deletion/save failures instead of silently swallowing them.
- Add tests for failed delete/save behavior if this moves into a testable store.

## Medium Priority

### Fix nested button semantics in SuggestionView

`SuggestionView` uses a tappable card button and places a second `Try This` button inside the card label. SwiftUI nested buttons can produce odd tap behavior and weak accessibility semantics.

Suggested direction:
- Make the card a non-button container with a clear expand tap target.
- Keep `Try This` as the only action button for selecting a practice.
- Add an interaction test if the UI grows beyond smoke coverage.

### Track and cancel async work

`RecordingViewModel` starts polling and analysis tasks without storing task handles. The returned tasks help tests wait for async work, but production still does not cancel in-flight work on view disappearance or repeated setup.

Suggested direction:
- Store task handles for recording meter polling and analysis.
- Cancel existing tasks before starting replacements.
- Consider a teardown hook from `RecordingScreen`.

### Clarify local secret setup

Production code requires a local ignored `Secrets.swift`, while the repo commits only `Secrets.swift.example`. A fresh clone may fail to build until the user creates the real file.

Suggested direction:
- Document first-run setup clearly in `README` or `docs/`.
- Consider a checked-in debug-safe fallback that compiles but returns an empty API key.
- Keep real keys ignored.

### Reduce repeated visual styling

Several SwiftUI views repeat gray rounded panels, card padding, and basic metadata row styling. This is not painful yet, but it will get noisy as the UI evolves.

Suggested direction:
- Extract small local view helpers only where duplication becomes meaningful.
- Avoid a broad design system until the interaction model settles.

## Low Priority

### Refresh stale testing documentation and specs

Some older docs/specs still refer to future protocol extraction or old keyword-ranking behavior. The architecture has moved on.

Suggested direction:
- Update `docs/testing.md` references to protocol extraction as future work.
- Review `openspec/specs/automated-tests/spec.md` for stale requirements around removed keyword matching/ranking.
- Keep `AGENTS.md` aligned when architecture changes.

### Keep OpenSpec archive/spec sync tidy

Archived changes are useful for context, but the main specs should remain the source of truth after a change is archived.

Suggested direction:
- Periodically scan `openspec/specs/` for requirements that no longer match implementation.
- Prefer modifying or removing stale requirements during future OpenSpec changes rather than letting contradictions pile up.
