## Context

The current recommendation flow shows a short practice summary and Gemini relevance text, then immediately asks whether the user tried the practice. This creates a gap: users are asked to reflect before Sift has shown a clear way to do the practice.

The practice library now includes richer fields such as steps, why-it-helps text, intensity, and avoid-when guidance. The UI should use those fields in a lightweight practice detail page while keeping Sift's tone non-dogmatic: the app offers one good path into a practice, not the authoritative version.

## Goals / Non-Goals

**Goals:**

- Insert a practice detail page between suggestion selection and reflection.
- Preserve the suggestion list as the place for comparing recommendations.
- Use the practice detail page as the place for actionable practice instructions.
- Present steps under "One way to practice" to support adaptation by experienced users.
- Keep "I did this" sticky and always enabled.
- Record a PracticeAttempt only after the user taps "I did this".
- Simplify reflection so it asks only whether the practice helped and optionally collects notes.

**Non-Goals:**

- Add timers, countdowns, or elapsed practice tracking.
- Add guided step-by-step pagination.
- Add media, audio guides, videos, or external content.
- Add next-day follow-up questions.
- Require users to scroll through all content before completing the practice.
- Preserve suggestion card expansion state after returning from the practice page.

## Decisions

### Add an explicit practicing state

Introduce a state between `suggesting` and `reflecting` that represents the selected practice detail page.

Alternatives considered:

- Reuse the existing reflection state and add steps above the "Did you try it?" question.
- Show steps inline inside expanded suggestion cards.

Rationale:

- Reflection and practice instruction are different jobs.
- Suggestion cards should stay compact enough for comparison.
- A dedicated practice page lets the user read, internalize, practice away from the screen, then return.

### "Try This" opens practice detail, not an attempt

Tapping "Try This" should not create a PracticeAttempt. It only means the user wants to inspect or try the practice.

Alternatives considered:

- Keep the current behavior where selection immediately creates an attempt.

Rationale:

- Selecting a practice is not the same as doing it.
- Attempt history should reflect practices the user says they completed.

### "I did this" records the attempt

The sticky "I did this" button creates a PracticeAttempt and transitions to reflection. The attempt may later be saved with `wasHelpful` true, false, or nil.

Alternatives considered:

- Create the attempt only after the user saves a helpfulness rating.

Rationale:

- Completing the practice is meaningful history even if the user skips helpfulness feedback.
- The existing model already supports attempts with nil helpfulness.

### Use a single scrollable page with a sticky completion action

The practice detail page should be one scrollable page with a bottom safe-area action for "I did this".

Alternatives considered:

- Step cards.
- Step-by-step paging.
- A non-sticky button only at the end of content.

Rationale:

- Experienced users may already know their own version of metta, box breathing, or similar practices.
- Users may read once, put the phone down, practice, then return.
- A sticky button avoids hunting for completion after practicing.
- Numbered steps are easier to scan and memorize than cards.

### Phrase steps as "One way to practice"

The steps section should be titled "One way to practice" instead of "How to do it".

Alternatives considered:

- "How to do it".
- "Instructions".

Rationale:

- Sift should not be dogmatic about embodied, contemplative, spiritual, or creative practices.
- The page should offer a path in while respecting that users may adapt or use familiar variants.

### Show safety guidance calmly and selectively

The practice detail page should show a subtle note when `avoidWhen` is non-empty or `intensity` is high. Low and medium intensity should not be shown by default.

Alternatives considered:

- Always show intensity.
- Use red warning styling.
- Hide avoid-when guidance entirely.

Rationale:

- Stronger practices need context, especially high-intensity breathwork.
- A calm note supports care without making the app feel medical or alarming.

## Risks / Trade-offs

- Additional state complexity → Mitigation: keep the new state small and use existing pending session/recommendation data for returning to suggestions.
- Sticky action may cover content → Mitigation: use a bottom safe-area container and add bottom padding to scroll content.
- Users may tap "I did this" without reading steps → Mitigation: this is acceptable for experienced users and aligns with the app's non-dogmatic posture.
- Current reflection tests assume the old "Did you try it?" phase → Mitigation: update view model and UI tests to reflect the new flow semantics.

## Migration Plan

1. Add a practice detail view that renders selected practice metadata and relevance.
2. Add a `practicing` recording state or equivalent state transition.
3. Change suggestion selection to open practice detail without logging an attempt.
4. Add an "I did this" action that logs the attempt and opens simplified reflection.
5. Simplify reflection UI and update tests.
6. Run full `xcodebuild test`.

## Open Questions

- Should the sticky button label remain "I did this" or become "Done" in any contexts?
- Should future guided timers live on this same page or a separate guided mode?
