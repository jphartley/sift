## Why

Sift is intended for vulnerable voice check-ins, so beta users need simple emotional-safety boundaries before they rely on the app without an in-person explanation. The app should feel supportive and relational while being clear that it offers reflection and practice suggestions, not therapy, medical care, or crisis support.

## What Changes

- Expand the Privacy tab's Safety section from a placeholder into plain-language guidance about what Sift is for, what it is not for, user agency, and urgent support.
- Keep the safety tone soft and relational: users should feel allowed to pause, skip, adapt, stop, or reach out to someone they trust.
- Refine the practice detail safety note so higher-intensity or context-sensitive practices remind users they can go slowly, adapt, or stop.
- Add or update automated tests that protect the safety copy and its placement.

## Capabilities

### New Capabilities

### Modified Capabilities

- `privacy-trust`: Expand the Privacy tab's Safety section into full emotional-safety guidance.
- `suggestion-interaction`: Update practice detail safety-note requirements to include user agency language.
- `automated-tests`: Add coverage expectations for the emotional-safety copy and practice detail safety note.

## Impact

- Affects `sift/Views/PrivacyScreen.swift` copy and tests around `PrivacyContent`.
- Affects `sift/Views/PracticeDetailView.swift` safety-note copy and any related view/content tests.
- Affects OpenSpec specs for privacy/trust, suggestion interaction, and automated tests.
- No data model, dependency, networking, or API changes are expected.
