# Intake Future Work

The first-time intake MVP intentionally stops at a compact persisted profile, prompt guidance, and local recommendation validation. The next product iteration should add ways for users to review, edit, or deepen that profile only after the core voice check-in loop has earned enough trust.

## Profile Review And Editing

- Add a privacy-forward profile surface that explains what Sift remembers from intake in plain language.
- Let users remove or revise hard constraints, soft priors, practice history signals, language preferences, evidence preferences, and coaching style.
- Keep edits local and persisted through the existing `UserPracticeProfile` SwiftData model unless a later migration requires a normalized record shape.
- Treat destructive profile resets as explicit user actions, separate from deleting session history.

## Later Optional Deepening

- Resurface optional intake questions after several check-ins or after a user skips the optional branch.
- Prefer one question at a time inside the existing check-in rhythm instead of introducing a long settings questionnaire.
- Use practice attempt feedback to decide which question would be most useful, such as duration preference, coaching style, or practices to avoid.
- Keep current check-in content primary; later deepening should refine recommendations, not interrupt a user who came to record.

## Validation Needs

- Add tests for profile editing persistence, profile reset behavior, and first-launch gating after a profile edit surface exists.
- Add tests that later optional questions do not appear during active recording, transcription, analysis, practice, or reflection states.
- Add copy tests for any user-facing explanation of stored profile data.
