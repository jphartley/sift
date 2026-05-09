## 1. Recovery Presentation

- [x] 1.1 Add a small check-in recovery presentation type with title, message, primary action label, optional secondary action label, and semantic recovery kind.
- [x] 1.2 Map microphone denial, model loading failure, empty speech, analysis failure, empty suggestions, and save failure to calm recovery presentations.
- [x] 1.3 Keep raw technical error details out of the primary user-facing recovery message.

## 2. Recovery UI

- [x] 2.1 Update `RecordingScreen` to render recovery presentation copy and actions instead of a generic error string where applicable.
- [x] 2.2 Add an "Open Settings" action for microphone permission recovery using the app's system Settings URL.
- [x] 2.3 Keep retry behavior for model loading and suggestion analysis.
- [x] 2.4 Add a "Record again" recovery path for empty or unusable speech.
- [x] 2.5 Ensure analysis failure and empty suggestion recovery preserve and reuse the existing transcript for retry.

## 3. Tests

- [x] 3.1 Add view-adjacent or unit tests for recovery presentation copy and action labels.
- [x] 3.2 Add view model tests for microphone denial, empty speech, analysis failure transcript preservation, empty suggestion retry, and save failure behavior.
- [x] 3.3 Add focused tests for the Settings action target without requiring the real Settings app to open.
- [x] 3.4 Update existing failure-path tests affected by replacing generic error strings.

## 4. Verification

- [x] 4.1 Run focused recovery-state tests.
- [x] 4.2 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 4.3 Perform a scoped cleanup pass and check whether `AGENTS.md` needs updates.
- [x] 4.4 Validate OpenSpec artifacts for `improve-calm-recovery-states`.
