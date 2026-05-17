## Context

Sift's core loop is voice check-in, on-device transcription, Gemini analysis, practice recommendation, practice attempt, and reflection. Today the system uses the current transcript, bounded prior session history, and the bundled YAML practice library to recommend practices. The first session has no personal context, so Gemini has little signal about the user's practice history, language boundaries, evidence preferences, or practices to avoid.

The intake flow should sit before the first check-in, remain skippable, and preserve the voice-first feel of the product. It should produce a compact persisted profile that improves prompts and filtering without replacing the core check-in loop.

## Goals / Non-Goals

**Goals:**
- Introduce a short first-time intake with a brief product introduction, three primary prompts, and an optional deeper tuning branch before the first check-in.
- Capture both structured chip selections and voice answers.
- Analyze intake answers into a persisted profile containing hard constraints, soft ranking priors, preferred language style, experience signals, and optional freeform source notes.
- Use intake constraints and priors in Gemini recommendation prompts and local recommendation validation.
- Support research-backed-only users by enriching practice metadata with explicit evidence grounding.
- Keep future profile editing and later optional-question resurfacing visible as backlog, not first-version scope.

**Non-Goals:**
- Add a full profile editor or settings surface for intake answers.
- Ask directly about trauma history or trauma sensitivity.
- Replace the check-in transcript as the primary recommendation signal.
- Add HealthKit, full conversational memory, or non-MVP onboarding education.
- Guarantee clinical suitability or medical advice.

## Decisions

### Decision: Model Intake Answers As Boundaries And Priors

The profile will distinguish hard constraints from softer recommendation priors.

Hard constraints include preferences such as secular-only language, no prayer, explicitly avoided practice types, or research-backed-only recommendations. The recommendation system must not violate these constraints unless the current check-in clearly and specifically requests an exception.

Soft priors include signals such as "breathwork helped sometimes," "journaling worked for me," "skeptical of meditation," preferred duration, and preferred tone. These should raise or lower recommendation ranking thresholds without fully excluding practices.

Alternative considered: store all intake answers as plain prompt context only. That is simpler, but it gives Gemini too much discretion around user boundaries and makes it harder to test whether the app respects explicit preferences.

### Decision: Use Voice-First Intake With Chips For Structure

Each primary intake question should offer quick chips and an optional voice answer. Chips provide reliable structured signals for constraints and categories. Voice captures nuance that users are unlikely to type during first launch.

The first-version intake should ask:
- What kind of support the user wants from Sift.
- What the user has tried before and how it landed.
- What boundaries or preferences Sift should respect.

The optional branch should ask a small number of deeper questions before the first check-in, including experience level, what tends to work during hard moments, what gets in the way, and preferred coaching style.

Alternative considered: a pure questionnaire. That would be easier to parse, but it would undercut the product's voice-first relationship and emotional-understanding goal.

### Decision: Analyze Intake Into A Compact Profile

The app should not store intake as only raw transcripts. It should analyze the structured and voice responses into a compact profile used by prompts and local validation. The raw voice transcript may be stored as source context for debugging or future re-analysis if the project already has an appropriate local storage pattern, but the recommendation path should depend on the normalized profile.

The profile should include:
- Completion state for first-time intake and optional branch.
- Desired support areas.
- Practice experience level.
- Practice history signals by practice family, including worked for me, helped sometimes, did not really help, and explicitly avoided.
- Language and worldview constraints, including secular-only and openness to spiritual language.
- Evidence requirement.
- Safety-oriented presentation preferences inferred from answers, such as avoiding closed-eye, body-focused, or intense practices when indicated.
- Preferred tone and duration constraints or priors.

Alternative considered: persist individual intake answer records only. That preserves detail, but it makes every recommendation prompt responsible for interpretation and complicates prompt construction.

### Decision: Enrich Practice Metadata For Evidence And Matching

The YAML practice library needs explicit evidence metadata so research-backed-only can be enforced before Gemini suggestions are accepted. Each practice should indicate whether it has explicit research grounding and include compact evidence notes or tags suitable for validation and prompt construction.

Preference matching metadata should also identify worldview/language framing and avoidable practice families where needed. For example, a practice can be eligible for secular presentation even if it comes from a contemplative tradition, but prayer-like or devotional practices should be excluded for secular-only users unless clearly requested in the current check-in.

Alternative considered: ask Gemini to infer evidence support from practice names and descriptions. That would be brittle and would make tests depend on model judgment instead of local catalogue data.

### Decision: Accept Mixed Preferences Conservatively

Most intake choices should not be mutually exclusive at the UI level. Users may coherently want secular framing while allowing spiritual language, research-backed practices while remaining open to contemplative language, or practical guidance with a spiritual flavor. The only boundary chip that should behave as mutually exclusive is "No preference."

Mixed preferences should be preserved in the profile and interpreted conservatively. For example, "Secular only" plus "Spiritual language is okay" means secular framing is required while spiritual or contemplative language is allowed only when it avoids religious doctrine, devotional framing, prayer, deity language, and tradition-dependent authority.

Alternative considered: force users to resolve tense combinations during intake. That would simplify profile interpretation, but it would make the intake less emotionally accurate and less respectful of how people actually describe their preferences.

### Decision: Treat Intake Copy As Product Contract

The approved intake copy should live in the spec, not only in implementation. These strings shape trust, voice encouragement, and boundary-setting, so implementation and tests should preserve them unless the spec is intentionally updated.

Alternative considered: leave exact copy to implementation. That would make the proposal less useful for review and make drift likely during build-out.

### Decision: Gate First Check-In Without Blocking Skips

On a clean install, users should see the intake before their first check-in. Every primary question should be skippable, and the user should be able to go directly to the first check-in after the three-question pass or skip intake entirely if needed. The optional deeper branch appears before the first check-in and can be declined.

Alternative considered: require intake completion before recording. That may improve profile quality, but it conflicts with the product principle that the core loop remains the center and that intake only makes Sift better.

### Decision: Defer Profile Review And Later Deepening

Profile review/editing and resurfacing optional intake questions after trust has built are intentional future work. The first version should leave clear backlog tasks or TODO-free product notes in OpenSpec rather than adding hidden UI or settings complexity now.

### Decision: Capture Per-Practice Sentiment In A Bottom Sheet

The prior practice prompt captures sentiment ("Worked for me", "Helped sometimes", "Didn't really help", "Please avoid") for each selected practice family through a bottom-sheet picker rather than inline chip rows. Tapping an unselected practice chip selects it and immediately presents the sentiment sheet. Tapping an already-selected chip reopens the sheet for change or removal. Sentiment remains optional; chips without an assigned sentiment are visually distinguished (dashed outline + lighter fill) to softly signal an unfinished state without blocking advancement.

The original first-version implementation rendered four sentiment chips inline below each selected practice. This pattern truncated chip labels at iPhone widths and produced an unreadable stack when multiple practices were selected.

Alternatives considered: a per-practice 4-segment segmented control (still tight on narrow screens and visually noisy with many selections); a separate Q2b step that walked through each practice one at a time (added friction to a flow we want to keep short); cycling sentiments by repeated taps on the chip (poor discoverability and accessibility); dropping structured sentiment entirely in favor of the voice answer (loses signal the recommendation engine can use deterministically).

### Decision: Gate Intake Navigation On Voice Transcription Completion

Voice answer transcription runs asynchronously after the user stops a recording. The Next action is disabled while transcription is in progress, with an inline "Transcribing…" indicator in the voice answer area. Skip remains enabled and cancels the in-flight transcription; this preserves the meaning of Skip as "I don't want this prompt" without forcing the user to wait for a transcript they don't intend to keep. Starting a new recording for the same prompt also cancels the previous in-flight transcription so that a stale transcript cannot land on a fresh take. On transcription failure, both actions are re-enabled and an inline error offers re-record or continue.

The original first-version implementation kicked off transcription as a fire-and-forget Task and left Next enabled, opening a race where a fast user could advance before the transcript was written to the intake response.

Alternatives considered: hard-blocking both Next and Skip during transcription (feels stuck and conflates "wait for this" with "skip this prompt"); allowing the user to proceed with a background banner that the transcript will catch up later (complex state and edge cases when the intake finishes before transcription does); a confirm-on-Next dialog (more interruption and worse than just disabling the button).

## Risks / Trade-offs

- Evidence metadata may be too thin at first -> Require tests that research-backed-only users receive only practices marked as explicitly grounded, and enrich the catalogue incrementally.
- Gemini may over-interpret a voice answer as permission to violate a hard constraint -> Include explicit prompt rules and local post-response validation before displaying recommendations.
- Intake may feel too long before the user experiences value -> Keep only three primary prompts before the optional branch and make skipping obvious.
- Voice-first intake adds transcription and analysis complexity before the main loop -> Reuse existing transcription and recommendation service boundaries where practical, with deterministic fakes for tests.
- Inferred safety preferences may be imperfect -> Prefer conservative presentation constraints and avoid asking directly about trauma in this version.
- Persisted profile schema may need migration later -> Keep the first profile compact and additive, and avoid over-normalizing speculative future fields.

## Migration Plan

1. Add the new profile model/storage and default existing installs to an incomplete intake state without disrupting existing sessions or practice attempts.
2. Add enriched practice YAML fields with defaults or complete catalogue updates in the same change so decoding remains deterministic.
3. Introduce intake UI before the first check-in and allow skip paths to mark intake as skipped or partially complete.
4. Feed the profile into prompt construction and recommendation validation.
5. Add backlog items for profile review/editing and resurfacing optional questions later.

Rollback is low-risk before release: remove the intake entry point and stop passing profile context to Gemini. Persisted profile records can remain unused if needed.

## Open Questions

- Should raw intake transcripts be persisted long-term, or should the app keep only the normalized profile and source snippets?
- What minimum evidence metadata is acceptable for "explicit research grounding": citation labels, human-readable notes, source URLs, or internal evidence tier labels?
- How strict should "Research-backed only" be for practices with adjacent evidence but no direct research on the exact practice variant?
