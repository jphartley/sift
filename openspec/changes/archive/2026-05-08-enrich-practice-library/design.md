## Context

The current practice library was built as an early YAML-backed test list. Each practice had a single `description`, which was enough for simple display but not enough for recommendation quality or future guided practice experiences.

The planning direction is to treat each practice as a small executable protocol: enough metadata for Gemini to match it well, enough plain-language context for users to understand why it was suggested, and enough steps for a later guided practice screen.

## Goals / Non-Goals

**Goals:**

- Migrate practice decoding from a single `description` to richer structured metadata.
- Expand the first four curated categories: Breathwork, Meditation, Grounding, and Movement.
- Keep one primary method-based `category` per practice.
- Use `labels`, `best_for`, `keywords`, `summary`, and `why_it_helps` to improve recommendation context.
- Keep the current suggestion UI simple by displaying `summary` where `description` used to appear.
- Preserve automated YAML decoding coverage and full test verification.

**Non-Goals:**

- Build a guided practice UI for `steps`.
- Show labels, safety guidance, or full step lists in the UI.
- Finish all 14 planned categories.
- Add media, videos, audio guides, or external content.
- Add runtime filtering based on `intensity` or `avoid_when`.

## Decisions

### Replace `description` rather than keeping compatibility fields

The `description` field is removed from the canonical schema and replaced with `summary`, `steps`, and `why_it_helps`.

Alternatives considered:

- Keep `description` as a fallback while adding new fields.
- Use a fully backward-compatible transitional decoder.

Rationale:

- The app is still in MVP development, so old bundled YAML compatibility is not needed.
- A clean schema prevents future content from drifting between duplicate fields.
- Tests now catch missing richer metadata early.

### Keep `category` singular and method-based

Each practice keeps one primary category such as Breathwork or Movement. Cross-cutting information lives in `labels`.

Alternatives considered:

- Add multiple categories per practice.
- Make categories need-based, such as Calm or Sleep.

Rationale:

- One primary category keeps recommendation diversity and future browsing simple.
- Labels can cover needs, contexts, and qualities without creating taxonomy soup.

### Include richer metadata in Gemini prompts, not full steps

Gemini receives the practice name, id, category, duration, intensity, labels, summary, best-fit situations, and why-it-helps text.

Alternatives considered:

- Include full practice steps in the prompt.
- Keep prompts limited to the old short description.

Rationale:

- Richer matching context should improve recommendation relevance.
- Omitting steps keeps prompt size more controlled while preserving the most useful selection signals.

### Display `summary` in existing UI surfaces

Suggestion cards and reflection state use `summary` as the short user-facing explanation.

Alternatives considered:

- Display `steps` immediately in expanded cards.
- Concatenate `summary` and `why_it_helps`.

Rationale:

- The current UI is designed around compact suggestion cards.
- Steps will need a dedicated guided practice surface to feel good.

## Risks / Trade-offs

- Larger YAML file → Mitigation: keep tests validating bundled decoding and non-empty required metadata.
- Gemini prompts become longer → Mitigation: include metadata useful for selection but not full steps.
- `intensity` and `avoid_when` are decoded but not enforced → Mitigation: include them in data now and defer runtime filtering to a later behavior change.
- Generated practice copy may need editorial review → Mitigation: treat this first pass as draft content and continue filtering/enrichment category by category.

## Migration Plan

1. Update `Practice` to decode the richer YAML schema.
2. Replace existing `description` usage with `summary`.
3. Replace the bundled YAML with the enriched first-pass library for completed categories.
4. Update tests and fixtures to require richer metadata.
5. Run full `xcodebuild test`.

Rollback strategy:

- Revert the schema and YAML changes together. Because the schema is intentionally breaking, partial rollback is not supported.

## Open Questions

- Which journaling practices should be selected from the candidate list?
- Should `intensity` become an enum instead of a string once runtime filtering exists?
- When should the UI display `steps`, `labels`, `why_it_helps`, or `avoid_when`?
- Should Gemini be instructed explicitly to avoid high-intensity practices in some transcript states?
