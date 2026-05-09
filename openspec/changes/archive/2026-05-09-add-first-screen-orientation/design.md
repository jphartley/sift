## Context

The Record tab currently enters the ready state with a prominent microphone button and the label "Tap to record." This is mechanically clear but does not orient beta users to the kind of check-in Sift supports, the approximate length, the low-pressure nature of the interaction, or the result of recording.

The internal beta audience is high-trust and may share vulnerable content. The first screen should therefore reduce uncertainty while keeping the recording action immediate and simple. This change is UI/copy only and should not alter the recording, transcription, recommendation, persistence, or history flows.

## Goals / Non-Goals

**Goals:**

- Help users understand how to begin without external explanation.
- Make the ready screen feel permissive by stating there is no right or wrong way to check in.
- Give a practical speaking boundary: about a minute.
- Explain the current product loop: transcribe on device, reflect back what was heard, suggest practices.
- Offer starter phrases that invite vulnerable but flexible check-ins.
- Keep the microphone action visually primary.
- Keep the check-in flow visually focused by removing the persistent navigation title.
- Use a simpler repeat-ready state when a prior transcript is visible.
- Cover the user-facing orientation with automated tests.

**Non-Goals:**

- Add a blocking onboarding flow.
- Add the full privacy/trust sheet from the separate P0 backlog item.
- Add crisis/safety guidance from the separate P0 emotional safety backlog item.
- Change recommendation prompts, Gemini behavior, persistence, or history.
- Introduce new dependencies or app architecture.

## Decisions

### Use inline ready-state orientation instead of a modal

The orientation will live directly in the ready recording screen. A modal or separate onboarding screen would add ceremony before the core loop and create another state to manage. Inline orientation keeps the app immediately usable while still explaining what to do.

Alternative considered: a first-run-only onboarding sheet. This may be useful later, especially for privacy and emotional safety, but it is more than the first-screen orientation item needs.

### Use settled coaching copy

The ready state will use the explored copy:

> Take a moment to arrive
>
> There is no right or wrong way to do this. Speak for about a minute about what feels most alive right now: what happened, how it feels, or what kind of support you want.
>
> Sift will transcribe your voice on device, reflect back what it heard, and suggest a few practices you can choose from.
>
> You might start with:
> "Right now I notice..."
> "What feels hard is..."
> "What I need is..."

This wording balances permission, coaching structure, and a small trust cue without turning the first screen into a privacy policy.

### Keep privacy copy lightweight

The ready screen should mention on-device transcription because it directly affects trust at the moment of recording. It should not name Gemini or include the full data flow; that belongs in the separate privacy/trust explanation backlog item.

### Preserve returning-user simplicity where practical

When a last transcript is visible, the ready state should use a shorter repeat instruction rather than the full first-time orientation and starter prompts. This keeps the second-use home screen from feeling like onboarding plus history plus recording controls all at once.

### Hide the persistent navigation title

The "Check In" navigation title appears throughout the check-in flow but does not add meaningful context beyond the selected Record tab and current screen content. The recording navigation bar should be hidden so the first screen and subsequent flow states can use the available vertical space for task-specific content.

## Risks / Trade-offs

- More copy may make the first screen feel busy on small devices -> Use scrollable or flexible vertical layout if needed so all content remains accessible.
- "Reflect back what it heard" may imply richer therapeutic reflection than the current transcript/analysis flow -> Keep downstream labels clear and revisit if beta users find the phrase misleading.
- On-device transcription trust cue may be mistaken for all analysis staying on device -> Address the full AI data flow in the separate privacy/trust backlog item.
- UI tests may be slow if used for static copy -> Prefer the lightest reliable test coverage available in the project, while still satisfying the behavior-change testing rule.
- Hiding the navigation title removes a conventional location label -> The Record tab selection and screen content should remain enough context for the current single-stack flow.
