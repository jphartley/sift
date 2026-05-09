## Why

The expanded practice library is valuable for the app UI, but the current Gemini prompt sends the full rich catalog and all prior sessions on every recommendation request. This makes prompt size grow with both the practice catalog and user history, increasing cost, latency, and future scaling risk.

## What Changes

- Send a compact Gemini-facing practice catalog while keeping `practices.yaml` as the rich source of truth for local UI display.
- Preserve Gemini's ability to choose from the full current practice library for now.
- Limit recommendation history to a smarter bounded list that includes recent sessions plus helpful prior practice attempts.
- Keep full transcript text for included history entries for now, since early check-ins are expected to be terse and may need their available detail.
- Leave local practice pre-filtering and aggregated history memory as future backlog items, not part of this change.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `gemini-practice-recommendation`: Change Gemini prompt requirements from complete rich library plus all history to compact full-library catalog plus bounded smart history selection.
- `gemini-service-composition`: Update prompt-builder behavior expectations so compact catalog and bounded history are independently testable.

## Impact

- Affects `GeminiPromptBuilder` prompt construction.
- Affects `SwiftDataSessionStore.recommendationHistory()` selection behavior.
- Affects Gemini prompt builder and session store tests.
- Does not change the YAML practice schema, local practice display, Gemini response schema, model routing, API key handling, or recommendation result persistence.
