# Backlog

Tracking voice check-in MVP status, product backlog items, and future follow-up work.

## External TestFlight Beta Readiness

Goal: a trusted person should be able to open Sift, understand what to say, feel safe saying it, receive a practice, and know what happened to their data without an in-person explanation.

Audience assumptions:
- Initial beta testers are close friends or people from trusted therapeutic settings.
- Check-ins may be vulnerable, so privacy confidence and emotional safety are core beta requirements.
- Sift should feel like a practical coach that recommends practices, while remaining open to journaling and reflection use cases.
- The first beta target is external TestFlight testers invited personally via WhatsApp, not broad public distribution.
- The main flow does not need to name the underlying LLM, but privacy copy should clearly explain what data is sent where.

| Item | Priority | Status | Notes |
|---|---|---|---|
| Calm recovery states | P1 | Done | Added calm recovery copy and actions for microphone permission denial with Open Settings, model loading failure, empty speech, analysis/network/API failure, empty suggestions, and save failure. |
| First-time prompt examples | P1 | Done | Covered by the Check In page orientation and starter prompts: "Right now I notice...", "What feels hard is...", and "What I need is...". More scenario-specific examples can wait unless beta feedback shows people still do not know what to say. |
| Human-facing suggestion explainability | P1 | Done | Suggestion rationale now uses coaching-flavored labels such as "Why these might fit" and "Why this might help"; model routing details such as Pro escalation are hidden from the main suggestion UI. |
| External TestFlight operations | P2 | To Do | Prepare build/version numbers, signing/archive/upload, external tester group, TestFlight "What to Test", feedback email, full test run, and a quick device smoke test. |

### External TestFlight Operations Checklist

Strictly necessary:
- [ ] Use external TestFlight testers invited personally via WhatsApp.
- [ ] Confirm the uploaded build has a working Gemini API key configured, not the safe placeholder. A separate beta key is optional for this trusted beta.
- [ ] Archive and upload a working build from Xcode.
- [ ] Add the processed build to a TestFlight tester group.
- [ ] Paste a short "What to Test" note into TestFlight.
- [ ] Add beta review notes that explain the reviewer path: open app -> Record tab -> allow microphone -> record a short check-in -> wait for transcription and suggestions -> choose a practice -> save a reflection.
- [ ] State in beta review notes that Sift is for reflection and wellness practice suggestions, not therapy, medical advice, diagnosis, or crisis support.
- [ ] Install the TestFlight build on a personal device and smoke test the full loop: open app -> Privacy tab -> record -> transcribe -> receive suggestions -> choose a practice -> reflect -> check History.
- [ ] Send the first WhatsApp invite to 2-3 trusted testers.

Nice to have:
- [ ] Name the tester group `Trusted Beta`.
- [ ] Track tester name, device, iOS version, and whether they completed one check-in.
- [ ] Keep a short known-issues note if any rough edges remain.
- [ ] Follow up after 24-48 hours with a gentle feedback prompt.

TestFlight "What to Test" draft:
> Please try one voice check-in. Notice whether you understand what to say, whether the privacy explanation feels clear, and whether the suggested practice feels useful, off, or surprising. Please also tell me if anything feels confusing, emotionally unsafe, or too rough around the edges.

WhatsApp invite draft:
> Hey, I am starting a tiny trusted beta for Sift, the voice check-in app I have been building. It lets you speak for about a minute, transcribes on your phone, and suggests a few practices you can choose from. I would love for you to try one check-in and tell me what feels clear, confusing, useful, or uncomfortable. No pressure to share personal details with me; I am mainly looking for feedback on the experience.

WhatsApp feedback prompt:
> Thank you for trying it. Three quick questions if you have a moment: 1. Did you know what to do when you opened it? 2. Did the privacy/safety explanation feel clear enough to trust it? 3. Did the suggested practice feel useful, irrelevant, or somewhere in between?

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

## Intake

Enhancements and follow-up work for the first-time intake flow.

| Item | Priority | Notes |
|---|---|---|
| Intake recording UI: match main check-in recording experience | Medium | Voice recording controls in intake feel unresponsive and give little visual feedback compared to the main check-in flow. Should use the same waveform animation, state transitions, and affordances. |
| Wrap-up screen after final intake question | Medium | After completing the last question the user is dropped directly into the check-in screen. A brief transition screen should acknowledge what Sift learned and set expectations for the first check-in. Content and tone TBD. |
| Affordance to resurface optional intake questions | Low | Users who skipped optional intake questions have no way to answer them later. Add an in-app surface (likely in Settings or Privacy tab) to answer or revisit optional intake questions after several check-ins. |
| Debug screen: reset intake profile for retesting | Low | Add a button in the Debug screen to clear the persisted UserPracticeProfile and re-trigger the first-time intake flow, enabling repeated testing without reinstalling the app. |

## Future Backlog Items

| Item | Priority | Notes |
|---|---|---|
| Scenario-specific check-in examples | Low | Optional follow-up if beta testers still seem unsure what to say. Could add rotating examples such as feeling tense after a conversation, replaying something from the day, or wanting one small practice before bed, but this should be driven by feedback rather than treated as a beta blocker. |
| Local practice pre-filtering before Gemini recommendation requests | Medium | The first compact-catalog pass reduced the Gemini practice-library prompt section from 56,265 chars (~14,066 estimated tokens) to 43,348 chars (~10,837 estimated tokens), a 12,917 char / ~3,229 token savings, or about 23%. This is useful but not a major reduction because Gemini still sees all 140 practices. The larger win is filtering locally to a smaller candidate set, for example 30-50 practices, before the Gemini call. |
| Aggregated user history context for recommendations | Medium | Replace raw recent-history excerpts with a higher-level summary of patterns, helpful practices, repeated stressors, and user preferences once enough history exists. |
