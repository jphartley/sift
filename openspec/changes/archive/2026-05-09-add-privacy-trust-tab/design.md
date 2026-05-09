## Context

The internal beta is moving toward users sharing more vulnerable voice check-ins. The app already records audio locally, transcribes with WhisperKit on device, deletes the temporary audio file after transcription, persists transcript/history locally through SwiftData, and sends text prompts to Gemini for recommendations. Users need a plain, visible explanation of that data flow before they can comfortably trust the app.

The privacy copy must be accurate without overpromising. The app can truthfully say audio is processed on the phone and not sent to Gemini. It can say Sift has no backend where check-ins are stored. It should not say "anonymous" without qualification, because the Gemini request uses Sift's developer API key and the transcript may contain identifying details the user says aloud. Since the beta uses a billing-enabled Gemini API project, the app can say Google states paid Gemini API prompts and responses are not used to improve Google products, while still noting that requests may be temporarily retained for service, safety, and abuse-prevention purposes.

## Goals / Non-Goals

**Goals:**

- Add a first-class Privacy tab in the main tab bar.
- Explain the data flow in simple, concrete language.
- Make clear that audio recording and transcription happen on the phone.
- Make clear that transcript text, not audio, is sent for AI suggestions.
- Explain that recent check-ins and practice helpfulness may be included as text context.
- Explain that history is stored locally and check-ins can be deleted from History.
- Explain that Jeremy does not have a server where check-ins are stored and cannot browse recordings, transcripts, or history.
- Mention Gemini only inside the body copy, not as a tab label or primary user-facing concept.
- Include Jeremy Hartley’s name, passion-project context, and contact email.
- Reserve space for a Safety section inside the Privacy tab, even if detailed safety copy lands later.
- Avoid logging transcript, prompt, or response text in developer console output.

**Non-Goals:**

- Add legal Terms of Service or a full privacy policy document.
- Add account identity, authentication, or user consent flows.
- Add remote analytics, crash reporting, or backend storage.
- Change the Gemini request data shape beyond removing unsafe debug logging.
- Add the full emotional-safety guidance now; this proposal only creates its place in the Privacy tab.

## Decisions

### Add a Privacy tab rather than a hidden sheet

The privacy explanation will be reachable as a top-level tab alongside Record and History. A sheet or small link would make the information feel secondary, while the beta trust goal requires it to be easy to find and revisit.

Alternative considered: a first-run privacy sheet from the Record tab. That may still be useful later, but the current ask is to make privacy a first-class citizen.

### Use simple sectioned copy

The Privacy tab will use short sections with direct headings:

- Privacy
- What happens when you record
- What I can see
- About AI suggestions
- Safety
- Questions

The opening copy will be:

> Sift is a small passion project by Jeremy Hartley. It is built to help people turn voice check-ins into practical wellness suggestions.

The data-flow copy should avoid jargon such as "inference", "retention policy", "LLM", or "backend" unless paired with plain-language explanation.

### Be careful with "anonymous"

The body copy should say Sift does not attach the user's name, email, or account to Gemini requests. It should also say that if the user says identifying details in a check-in, those words are part of the transcript sent to Gemini.

This is more accurate than simply saying "anonymous", while preserving the trust point that Sift is not sending an app account identity with the transcript.

### Mention Gemini only inside body copy

Most users will not know or care what Gemini is. The tab should be named Privacy, and a body section can say Sift sends text to Gemini for AI suggestions.

### Remove risky developer logging

The implementation should not print transcript, full prompt, or model response text. Current logs that include model names, prompt length, history count, confidence, escalation, and practice IDs are acceptable for debugging because they do not include the user's raw check-in text. Any partial-response text logging should be removed because model responses may reflect user-provided content.

## Risks / Trade-offs

- Plain language can become imprecise -> Use direct claims only when verified by the current implementation and Gemini API terms.
- Saying "on your phone" may imply every step is local -> Pair it with clear text that transcript text is sent for AI suggestions.
- Saying Sift does not attach account identity may be read as full anonymization -> Explicitly note that identifying details spoken by the user remain in the transcript.
- Provider policies may change -> Include a "Last updated: May 2026" line and keep provider-specific language easy to revise.
- A third tab adds navigation weight -> Privacy is a beta trust requirement and worth the tab-space cost.
