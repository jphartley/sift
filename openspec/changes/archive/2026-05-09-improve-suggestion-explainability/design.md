## Context

The current suggestion screen already receives the data it needs: transcript, rationale, practice list, per-practice relevance text, previously-helpful IDs, and whether routing escalated to Pro. The beta-readiness gap is presentation: "Analysis" and "Escalated to Pro model" expose implementation framing at the exact moment users should feel met and oriented.

## Goals / Non-Goals

**Goals:**

- Make recommendation explanations feel like coaching context rather than model output.
- Keep rationale and per-practice relevance visible because they help users choose a practice.
- Remove model/provider/routing/confidence terms from the main suggestion UI.
- Keep routing, persistence, and debug metadata behavior intact behind the scenes.
- Make copy testable without relying on brittle full UI automation where a view-adjacent presentation surface is enough.

**Non-Goals:**

- Changing Gemini prompts, models, routing thresholds, or retry behavior.
- Changing the persisted Session schema or historical metadata fields.
- Rewriting the suggestion card interaction pattern.
- Removing provider/model transparency from the Privacy tab or developer-oriented diagnostics.

## Decisions

- Use user-facing labels such as "Why these might fit" for the overall rationale and "Why this might help" for per-practice relevance. This keeps the explanation practical and soft without implying certainty.
- Remove the `wasEscalated` toast from the main suggestion screen. The `wasEscalated` value can still exist in state and tests can continue to verify routing internally, but it should not create beta-facing UI.
- If new constants or a small presentation type are introduced, keep them close to `SuggestionView` and cover them with Swift Testing. This matches the existing pattern used for Privacy, recording orientation, recovery, and practice detail copy tests.
- Preserve "Try one of these" and the accordion behavior unless implementation reveals a small label adjustment is needed for consistency.

## Risks / Trade-offs

- Hiding model escalation reduces live debugging visibility in the app UI. Mitigation: keep metadata persisted and keep routing tests focused on internal behavior.
- Softer labels can become too vague. Mitigation: use labels that still answer the user's likely question: why these suggestions, and why this practice.
- SwiftUI view hierarchy assertions can be brittle. Mitigation: prefer testing view-adjacent copy/presentation data and only add UI-level tests where they provide meaningful coverage.
