## Context

The check-in flow currently routes many different failures through a generic `.error(String)` state and a shared warning screen with a single Retry button. That is workable for development, but it is not good enough for internal TestFlight users who may be making vulnerable voice check-ins and may not have Jeremy nearby to explain what went wrong.

Microphone permission denial is the most important recovery case because the app cannot perform its core function without microphone access. Analysis and network failures are also sensitive because they happen after the user has already spoken and expects care with their check-in.

## Goals / Non-Goals

**Goals:**
- Give recoverable check-in failures calm, specific, plain-language presentation.
- Add an "Open Settings" action for microphone permission denial.
- Keep recommendation retry behavior while clearly saying the transcript is still available.
- Invite users to record again when speech is empty or unusable without implying they did anything wrong.
- Keep recovery copy and actions testable without needing live microphone, WhisperKit, or Gemini requests.

**Non-Goals:**
- Add a full permission onboarding flow before the user reaches the recording screen.
- Add automatic permission polling after returning from Settings.
- Add network diagnostics, offline mode, local fallback recommendations, or Gemini retry backoff.
- Change the successful check-in, practice suggestion, practice completion, or reflection flows.
- Change persistence models or service protocols unless needed to carry recovery presentation cleanly.

## Decisions

1. Introduce a small recovery presentation layer for check-in failures.

Recovery states should have a title, message, primary action label, optional secondary action label, and a semantic kind. This keeps user-facing copy out of ad hoc error strings and makes the beta tone easy to test.

Alternative considered: continue passing raw error strings into the generic error view. That is simpler but keeps technical wording and action choice scattered across failure sites.

2. Treat microphone permission denial as a distinct recovery kind.

The microphone-denied recovery should explain that Sift needs microphone access to record a check-in and offer "Open Settings" as the primary action. "Try again" can remain available for users who return after changing permission.

Alternative considered: keep only a Retry button. That leaves users stuck because iOS will not show the permission prompt again after denial.

3. Preserve the transcript for analysis failures.

When recommendation analysis, network, API-key, or empty-suggestion failures occur after transcription, the recovery screen should state that the check-in text is still available and offer retrying suggestions. This protects the most emotionally sensitive moment in the flow.

Alternative considered: reset to ready after analysis failures. That would be faster to implement but risks making the user feel their check-in disappeared.

4. Use "record again" language for empty or unusable speech.

If transcription produces no useful text, the recovery should invite another short check-in and reassure users that a sentence or two is enough. This should feel like a normal retry, not user failure.

Alternative considered: treat empty speech as a technical transcription failure. That would produce less helpful guidance for a common beta mistake such as silence, interruption, or tapping too quickly.

5. Keep the UI visually calm.

Recovery screens should avoid alarming red treatment for non-emergency failures. The app can still use an icon, but the copy and action should do most of the work.

Alternative considered: use a warning-triangle error template everywhere. It is visible, but it gives minor recoverable states more threat energy than this product needs.

## Risks / Trade-offs

- Recovery cases multiply and complicate state handling → Keep the first version scoped to the beta-critical states from the backlog.
- "Open Settings" is hard to unit test as a real system side effect → Keep the URL/action behind a view-level closure or injectable opener and test the presentation/action availability.
- Empty speech detection may be too strict or too loose → Start with a simple trimmed-empty transcript rule and refine if beta users hit near-empty transcripts.
- Softer copy may hide serious configuration failures → Preserve diagnostic detail where useful in tests/logs, but keep user copy calm and actionable.
