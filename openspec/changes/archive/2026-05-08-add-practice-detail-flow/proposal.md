## Why

The current check-in flow asks whether the user tried a suggested practice immediately after selection, but it does not show the user how to do the practice. Now that practices have richer steps and explanatory metadata, Sift should insert a lightweight practice detail page between recommendations and reflection.

## What Changes

- Add a practice detail flow after tapping "Try This" from a recommendation card.
- Change "Try This" semantics so it opens the practice detail page without recording a PracticeAttempt.
- Add a sticky "I did this" action on the practice detail page; tapping it records the PracticeAttempt and moves to reflection.
- Display practice summary, personalized Gemini relevance, numbered steps under "One way to practice", why-it-helps text, and a subtle safety note when applicable.
- Simplify reflection by removing the "Did you try it?" step; reflection asks only whether the completed practice helped and optionally collects notes.
- Preserve back navigation from the practice detail page to suggestions without logging an attempt.
- Do not add timers, guided step pagination, media, or next-day follow-up behavior in this MVP change.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `suggestion-interaction`: "Try This" opens practice detail before reflection, and practice detail presents the actionable practice content.
- `practice-loop`: Practice attempts are created when the user taps "I did this", not when they first select a recommendation.

## Impact

- Affected code likely includes:
  - `RecordingState` and `RecordingViewModel`
  - `RecordingScreen`
  - `SuggestionView`
  - `ReflectionView`
  - a new practice detail view
  - related view model and UI tests
- No new dependencies.
- Uses existing enriched practice fields: `summary`, `steps`, `whyItHelps`, `avoidWhen`, `intensity`, `category`, and `durationMinutes`.
