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
