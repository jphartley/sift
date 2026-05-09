# Backlog

Tracking voice check-in MVP status, product backlog items, and future follow-up work.

## Internal TestFlight Beta Readiness

Goal: a trusted person should be able to open Sift, understand what to say, feel safe saying it, receive a practice, and know what happened to their data without an in-person explanation.

Audience assumptions:
- Initial beta testers are close friends or people from trusted therapeutic settings.
- Check-ins may be vulnerable, so privacy confidence and emotional safety are core beta requirements.
- Sift should feel like a practical coach that recommends practices, while remaining open to journaling and reflection use cases.
- The first beta target is Internal TestFlight, not broad external distribution.
- The main flow does not need to name the underlying LLM, but privacy copy should clearly explain what data is sent where.

| Item | Priority | Status | Notes |
|---|---|---|---|
| First-time prompt examples | P1 | To Do | Add example check-in prompts such as feeling tense after a conversation, replaying something from the day, or wanting one small practice before bed. |
| Human-facing suggestion explainability | P1 | To Do | Keep "Why this was suggested" while making rationale feel like coaching instead of model output; hide implementation details such as model escalation from beta users unless needed for debugging. |
| Calm recovery states | P1 | To Do | Improve copy and actions for microphone permission denial, model download/loading, empty speech, analysis failure, and network/API failure. |
| Internal TestFlight operations | P2 | To Do | Prepare build/version numbers, signing/archive/upload, internal tester group, TestFlight "What to Test", feedback email, full test run, and a quick device smoke test. |

## MVP Feature Status

PRD and supplement requirements against the voice check-in MVP.

| Item | Priority | Status |
|---|---|---|
| Voice recording + on-device transcription (WhisperKit) | Highest | Done |
| AI practice suggestions with Gemini rationale + relevance scores | Highest | Done |
| Two-tier Flash/Pro model routing with confidence thresholds | Highest | Done |
| Practice library rich schema + expanded category library | Highest | Done |
| Practice detail page with steps and completion action | Highest | Done |
| Practice reflection (helpfulness + optional notes) | Highest | Done |
| Session + PracticeAttempt history persisted via SwiftData | Highest | Done |
| History screen with session detail views | Highest | Done |
| Practice timer for guided/solo practice sessions | Medium | To Do |
| Conversational back-and-forth chat (multi-turn, follow-up questions) | Highest | To Do |
| Mood/context tagging (explicit labels, selectable tags) | Highest | Partially Done |
| "Just Show Me" cheat sheet mode (one-tap logging, minimal friction) | Highest | To Do |
| Prior wins surfaced on return / context from past sessions | Medium | Partially Done |
| AI-generated session well-being summary | Medium | Partially Done |
| AI memory & longitudinal intelligence (trends, patterns, seasonality) | Medium | To Do |
| Practice management: trial thresholds, resistance scoring, rotation, retirement | Medium | To Do |
| Weekly narrative summary | Medium | To Do |
| Memory architecture (stable facts, episodic memory, vector index) | Medium | To Do |
| Conversational memory corrections | Medium | To Do |
| HealthKit integration (HRV, sleep, heart rate, activity) | High | Out of Scope |
| Apple Watch integration | High | Out of Scope |
| Conversational onboarding / first-time user experience | Medium | To Do |

**Status key**
- **Done** — Implemented and working in the current build
- **Partially Done** — Some aspect exists but the full requirement is incomplete
- **To Do** — Planned but not yet started
- **Out of Scope** — Deliberately excluded from the current MVP phase

## Future Backlog Items

| Item | Priority | Notes |
|---|---|---|
| Local practice pre-filtering before Gemini recommendation requests | Medium | The first compact-catalog pass reduced the Gemini practice-library prompt section from 56,265 chars (~14,066 estimated tokens) to 43,348 chars (~10,837 estimated tokens), a 12,917 char / ~3,229 token savings, or about 23%. This is useful but not a major reduction because Gemini still sees all 140 practices. The larger win is filtering locally to a smaller candidate set, for example 30-50 practices, before the Gemini call. |
| Aggregated user history context for recommendations | Medium | Replace raw recent-history excerpts with a higher-level summary of patterns, helpful practices, repeated stressors, and user preferences once enough history exists. |
