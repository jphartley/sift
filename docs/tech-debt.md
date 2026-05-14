# Technical Debt

Working list of refactor and maintenance areas worth addressing after the voice check-in MVP stabilizes. Separate from `backlog.md`, which tracks product scope — this file tracks code health and architecture pressure.

## Medium Priority

### Fix HistoryScreen pill showing practiceID instead of practiceName

`HistoryScreen.sessionRow` renders the practice **slug** (`box-breathing`) in the pill instead of the human name (`Box Breathing`):

```swift
// HistoryScreen.swift:172
PillTag(text: attempt.practiceID, tone: .soft)
```

`PracticeAttempt` already denormalizes `practiceName` for exactly this case. One-line fix to use `attempt.practiceName`. Pair with the `HistoryScreen` row regression test in [test-system-improvement.md](test-system-improvement.md) so this doesn't reappear.

### Fix nested button semantics in SuggestionView

`SuggestionView` uses a tappable card button and places a second `Try This` button inside the card label. SwiftUI nested buttons can produce odd tap behavior and weak accessibility semantics.

Suggested direction:
- Make the card a non-button container with a clear expand tap target.
- Keep `Try This` as the only action button for selecting a practice.
- Add an interaction test before changing the behavior (see [test-system-improvement.md](test-system-improvement.md)).

### Reduce repeated visual styling

Several SwiftUI views repeat gray rounded panels, card padding, and basic metadata row styling. Not painful yet, but will get noisy as the UI evolves.

Suggested direction:
- Extract small local view helpers only where duplication becomes meaningful.
- Avoid a broad design system until the interaction model settles.

## Low Priority

### Test infrastructure

See [test-system-improvement.md](test-system-improvement.md) for the full prioritized checklist. Top remaining items:

- Add a GitHub Actions workflow running `xcodebuild test` on every PR.
- Once CI is in place, trial mutation testing (`muter`) against `GeminiRecommendationRouter`, `GeminiRecommendationParser`, and `selectRecommendationHistory()`. These contain boundary conditions that line coverage alone won't validate.
