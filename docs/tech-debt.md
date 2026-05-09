# Technical Debt

Working list of refactor and maintenance areas that are worth addressing after the voice check-in MVP stabilizes. This is intentionally separate from `backlog.md`: backlog tracks product scope and future product follow-up work, while this file tracks code health and architecture pressure.

## Medium Priority

### Fix nested button semantics in SuggestionView

`SuggestionView` uses a tappable card button and places a second `Try This` button inside the card label. SwiftUI nested buttons can produce odd tap behavior and weak accessibility semantics.

Suggested direction:
- Make the card a non-button container with a clear expand tap target.
- Keep `Try This` as the only action button for selecting a practice.
- Add an interaction test if the UI grows beyond smoke coverage.

### Reduce repeated visual styling

Several SwiftUI views repeat gray rounded panels, card padding, and basic metadata row styling. This is not painful yet, but it will get noisy as the UI evolves.

Suggested direction:
- Extract small local view helpers only where duplication becomes meaningful.
- Avoid a broad design system until the interaction model settles.

## Low Priority
