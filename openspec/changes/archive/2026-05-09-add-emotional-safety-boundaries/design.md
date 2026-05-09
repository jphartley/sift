## Context

Sift is preparing for an internal TestFlight beta with high-trust users who may speak vulnerably during check-ins. The app already has a first-class Privacy tab with a placeholder Safety section, and practice details can show a calm note for high-intensity or context-sensitive practices.

The next beta-readiness gap is emotional safety: users should understand that Sift offers reflection and practical wellness suggestions, not therapy or crisis support, and they should feel free to stop, adapt, or reach out for human support.

## Goals / Non-Goals

**Goals:**
- Replace placeholder safety copy with simple, soft, relational guidance.
- Make user agency explicit: pause, skip, adapt, or stop any practice.
- Include direct-but-gentle urgent-support language for moments when a user does not feel safe.
- Echo the same agency language in contextual practice detail safety notes.
- Cover the content with focused tests so future edits do not accidentally weaken the beta safety boundary.

**Non-Goals:**
- Add crisis detection, automated escalation, emergency calling, or triage.
- Add location-specific hotline routing or external safety-resource lookup.
- Add legal, medical, or clinical disclaimers beyond plain-language boundaries.
- Change recommendation routing, persistence, transcription, or model behavior.

## Decisions

1. Keep safety guidance inside the Privacy tab for beta.

The Privacy tab is already the first-class trust surface and contains the existing Safety section. Expanding that section avoids adding a new tab or modal before beta, while still making safety easy to find.

Alternative considered: show a mandatory first-run safety screen. That may become useful later, but it adds onboarding complexity before we know how beta users move through the app.

2. Use soft relational copy rather than a defensive disclaimer.

The copy should say what Sift is and is not, then give users permission to choose the gentlest next step available. This matches the product tone better than dense legal language.

Alternative considered: use formal medical disclaimer language. That might be more explicit, but it would make the app feel less emotionally attuned and less aligned with the trusted-beta audience.

3. Keep urgent-support guidance general.

The beta version should tell users to contact emergency support or a trusted person right away if they feel at risk or unsafe, without trying to provide country-specific resources.

Alternative considered: include US-only crisis line copy. The user is in the US, but beta testers may not all be in the same jurisdiction, and location-specific resource accuracy is a larger product commitment.

4. Update practice detail notes to reinforce agency.

The existing practice detail safety note appears only when a practice is high intensity or has avoid-when guidance. It should continue to be contextual, but use language that reminds users they can go slowly, adapt, or stop.

Alternative considered: show the same safety note on every practice. That would increase visibility but could make low-intensity practices feel heavier than needed.

## Risks / Trade-offs

- Safety copy becomes too soft and users miss the boundary → Include clear statements that Sift is not therapy, medical care, or crisis support.
- Safety copy becomes too alarming and discourages use → Keep the voice calm, relational, and permission-based.
- General emergency guidance is less actionable than location-specific resources → Keep this scoped for internal beta and revisit resource routing before a broader launch.
- Copy changes regress later → Add focused unit/UI coverage for the Safety section and practice detail note language.
