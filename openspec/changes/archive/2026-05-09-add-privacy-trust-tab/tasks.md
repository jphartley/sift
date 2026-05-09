## 1. Privacy Content

- [x] 1.1 Add Privacy screen presentation data containing the approved plain-language sections and copy.
- [x] 1.2 Include the intro, recording data flow, developer access, AI suggestions, Safety, Questions, contact, and last-updated content.
- [x] 1.3 Ensure the copy avoids overclaiming anonymity and describes Gemini requests accurately for a billing-enabled API project.

## 2. Privacy Tab UI

- [x] 2.1 Add a new `Privacy` tab to the main `TabView`.
- [x] 2.2 Implement a scrollable Privacy screen that renders the sectioned copy clearly.
- [x] 2.3 Keep Gemini mentioned only in the body copy, not the tab label or primary screen title.

## 3. Logging Guardrail

- [x] 3.1 Remove any developer console logging that can print transcript text, full prompt text, or raw Gemini response text.
- [x] 3.2 Preserve metadata-only logging if useful, such as model name, prompt length, history count, confidence, escalation state, and practice IDs.

## 4. Test Coverage

- [x] 4.1 Add automated coverage for the Privacy tab presence.
- [x] 4.2 Add automated coverage for the privacy/trust presentation data and key copy claims.
- [x] 4.3 Add automated or static coverage for sensitive logging guardrails.
- [x] 4.4 Run focused tests for the new/changed coverage.
- [x] 4.5 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` before completion.

## 5. Cleanup

- [x] 5.1 Perform a scoped cleanup pass for the changed UI, tests, and logging code.
- [x] 5.2 Check whether `AGENTS.md` needs updates; leave it unchanged if architecture, dependencies, commands, and workflows are unchanged.
