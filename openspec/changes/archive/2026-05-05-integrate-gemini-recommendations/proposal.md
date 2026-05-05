## Why

The current keyword-matching recommendation system is brittle — it can't understand semantic meaning ("I feel like I'm drowning at work" won't match "overwhelm") and makes no attempt to explain its choices. Adding Gemini gives the app real comprehension and a rationale that builds user trust.

## What Changes

- Add Google Generative AI SDK as a second SPM dependency
- Add `Secrets.xcconfig` (gitignored) with `GEMINI_API_KEY`, injected at build time
- Add `GeminiService` (`@Observable`) for LLM-based practice recommendation, injected alongside `TranscriptionService`
- Add `RecordingState.analyzing` between transcribing and suggesting
- Replace keyword matching with Gemini-driven recommendation (no offline fallback for MVP)
- Send full user history (all prior sessions with transcripts, practices tried, and helpfulness) in the prompt
- Gemini returns structured JSON: practice recommendations with per-practice relevance text and an overarching rationale
- Route requests to `gemini-3-flash-preview` by default, escalate to `gemini-3.1-pro-preview` when confidence < 0.7
- Display rationale and per-practice relevance in `SuggestionView`
- Persist Gemini rationale, model used, and confidence on `Session`
- Show a developer-visible notification when Pro escalation occurs
- Show inline error with retry button when Gemini is unreachable or returns invalid output

## Capabilities

### New Capabilities

- `gemini-practice-recommendation`: Using Gemini to analyze voice check-in transcripts with full user history and recommend 2–3 wellness practices with an overarching rationale and per-practice relevance text

### Modified Capabilities

- `voice-check-in`: The "System suggests practices after transcription" requirement changes from keyword matching to LLM-based recommendation; the transcription-to-suggestion flow gains an analysis step with its own loading state, error handling, and retry

## Impact

- New dependency: `google-generative-ai-swift` (SPM, version latest stable)
- New file: `Secrets.xcconfig` (gitignored, build-time injected)
- New file: `sift/Services/GeminiService.swift`
- Modified: `RecordingViewModel` — new analysis step, Gemini service integration
- Modified: `RecordingState` enum — new `.analyzing` case
- Modified: `Session` model — new `geminiRationale`, `geminiModelUsed`, `geminiConfidence` fields
- Modified: `SuggestionView` — rationale display, relevance text, Pro escalation indicator
- Modified: `RecordingScreen` — new analyzing state UI
- Modified: `siftApp.swift` — GeminiService instantiation and injection
- Modified: `sift.xcodeproj/project.pbxproj` — new SPM dependency, xcconfig references
- Modified: `.gitignore` — `Secrets.xcconfig`
