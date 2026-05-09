## Why

Internal beta users may share vulnerable voice check-ins, so privacy and trust need to be visible, plain-spoken, and easy to revisit. A first-class Privacy tab should explain exactly what happens to audio, transcripts, AI requests, local history, developer access, and contact/support in language users can understand without legal or technical background.

## What Changes

- Add a first-class `Privacy` tab to the main tab bar.
- Present a plain-language privacy/trust screen explaining:
  - audio recording and transcription happen on the phone
  - temporary audio is deleted after transcription
  - transcript text, not audio, is sent for AI suggestions
  - recent check-in text and helpfulness history may be included for better suggestions
  - check-in history is stored locally on the phone and can be deleted from History
  - Sift has no developer backend where check-ins are stored
  - the developer cannot browse recordings, transcripts, or history
  - Gemini is used for AI suggestions, but only in body copy rather than as the tab label
  - Sift does not attach the user's name, email, or account to Gemini requests
  - identifying details spoken by the user remain part of the transcript sent to Gemini
  - paid Gemini API prompts/responses are not used to improve Google products, while requests may be temporarily retained for service, safety, and abuse-prevention purposes
- Include a personal About section for Jeremy Hartley and contact email `jphartley@gmail.com`.
- Add a placeholder Safety section within the Privacy tab for later emotional-safety copy.
- Ensure user-facing claims are aligned with implementation by avoiding transcript/response content in developer console logs.
- Add or update tests for the tab, privacy copy, and any logging/data-handling guardrails introduced.

## Capabilities

### New Capabilities

- `privacy-trust`: Defines the user-facing privacy/trust tab and its required plain-language disclosures.

### Modified Capabilities

- `automated-tests`: Automated coverage shall verify the Privacy tab, key privacy copy, and logging/data-handling expectations.

## Impact

- Affected UI: `ContentView` and a new Privacy view under `sift/Views/`.
- Affected services: Gemini logging may be adjusted to avoid printing any potentially sensitive request/response content.
- Affected tests: add view-adjacent or UI coverage for privacy copy and tab presence; update Gemini service/router tests if logging behavior changes.
- No persistence model, external dependency, or network API changes are expected.
