## Context

`practices.yaml` now contains a rich catalog of 140 practices. The app needs that rich data locally for practice detail screens, but `GeminiPromptBuilder` currently serializes every practice with full matching metadata into each Gemini recommendation prompt. `SwiftDataSessionStore.recommendationHistory()` also returns every prior session, and prompt construction includes full transcripts for every returned entry.

The near-term product decision is to keep Gemini choosing from the whole practice library, preserve full transcript detail for selected history entries, and avoid local practice pre-filtering or aggregated memory until later.

## Goals / Non-Goals

**Goals:**

- Reduce Gemini prompt size by sending a compact practice catalog instead of rich practice prose.
- Keep all current practices eligible for Gemini recommendation.
- Bound history included in recommendation context using a smarter recent-plus-helpful selection.
- Preserve full transcripts for history entries that are included.
- Keep prompt construction and history selection covered by focused tests.

**Non-Goals:**

- Do not change the YAML practice schema.
- Do not change practice detail display or local practice lookup.
- Do not add local practice pre-filtering in this change.
- Do not add aggregated user memory or summary generation in this change.
- Do not change Gemini model routing, response schema, API key handling, or persistence fields.

## Decisions

1. Use a compact prompt formatter inside `GeminiPromptBuilder`.

   The prompt builder will still receive `[Practice]`, but each prompt entry will include only recommendation-selection fields: id, name, category, duration, intensity, labels, best-fit situations, and summary. It will omit `steps`, `avoid_when`, keywords, and `why_it_helps`.

   Alternative considered: create a separate persisted Gemini catalog file. This adds synchronization risk with `practices.yaml` and is unnecessary while the local model already has all needed fields.

2. Keep the full practice set in the compact catalog.

   Gemini will still choose from the complete library for now. This avoids introducing local ranking behavior before the app has enough real usage data to validate it.

   Alternative considered: local keyword pre-filtering. This is useful later, but it could hide good recommendations early and would need its own quality evaluation.

3. Select bounded smart history in `SwiftDataSessionStore`.

   The session store will return a deterministic bounded list consisting of recent sessions plus older sessions with helpful practice attempts, de-duplicated and ordered for prompt readability. The included entries will retain full transcript text.

   Alternative considered: pure most-recent history. That is simpler, but it loses older practices the user explicitly marked helpful.

4. Keep future memory aggregation out of this implementation.

   Aggregated user history belongs in a future memory layer. This change only constrains raw history context so the current prompt remains predictable.

## Risks / Trade-offs

- Compact practice entries may remove nuance that helped Gemini choose between similar practices. → Keep summaries, labels, and best-fit situations, and rely on local full details after Gemini returns IDs.
- Helpful older sessions could crowd out recent context if limits are too small. → Use separate recent and helpful caps so both signals survive.
- Full transcripts can still be large when users record long sessions. → Accept this for now based on expected terse early usage; revisit with aggregation or transcript excerpts later.
- Selection order can affect prompt interpretation. → Use deterministic ordering and cover it in tests.
