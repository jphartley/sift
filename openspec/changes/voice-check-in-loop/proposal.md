## Why

The current prototype only validates WhisperKit transcription accuracy — it registers zero wellness value for a real user. A voice-first check-in loop that suggests wellness practices based on what the user shares is the smallest meaningful step toward Sift's core promise: a companion that helps you discover and retain the few practices that work for you. Building this now converts the transcription infrastructure from a test harness into an actual product experience.

## What Changes

- Evolve the record → transcribe → "was it accurate?" flow into a record → transcribe → "here's what to try" flow
- Introduce a curated practice library (hardcoded list of evidence-based wellness practices)
- After transcription, display 2–3 practice suggestions based on the user's spoken context (simple keyword matching in V1, no LLM)
- Replace the transcription-accuracy rating UI with a practice-reflection UI (did you try it? did it help?)
- Add Session and PracticeAttempt data models to capture user sessions and what was tried (replacing the TestResult model — **BREAKING**)
- Add a basic History view that shows past sessions and which practices helped
- Surface previously helpful practices first (rudimentary memory)

## Capabilities

### New Capabilities
- `voice-check-in`: Voice recording → WhisperKit transcription → practice suggestion display. Manages the recording lifecycle, transcription pipeline, and result presentation.
- `practice-loop`: Curated practice library, practice suggestion matching (keyword-based), practice logging (done/not done), helpfulness reflection (thumbs up/down), and basic memory (surfacing previously helpful practices first).

### Modified Capabilities
<!-- None — this is the first product feature change. -->

## Impact

- Replaces `Models/TestResult.swift` with new Session and PracticeAttempt models
- Modifies `RecordingViewModel.swift` to drive the new flow (transcription → practice suggestions → reflection)
- Adds `Models/Practice.swift` for the practice library data
- Replaces `Views/ResultScreen.swift` with practice-suggestion and reflection UI
- Replaces `Views/HistoryScreen.swift` with session + practice-attempt history
- Modifies `Views/RecordingScreen.swift` to match the new flow
- SwiftData schema migration needed (TestResult → Session + PracticeAttempt)
- No external dependencies or API changes
