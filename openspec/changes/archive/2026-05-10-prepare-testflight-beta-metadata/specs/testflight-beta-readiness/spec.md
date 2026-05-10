## ADDED Requirements

### Requirement: App metadata is beta-facing

The app target SHALL expose user-facing metadata suitable for an external TestFlight beta build.

#### Scenario: Installed app name is Sift
- **WHEN** the app is installed from a beta build
- **THEN** the displayed app name SHALL be "Sift"

#### Scenario: Microphone permission prompt matches check-in purpose
- **WHEN** iOS asks the user for microphone permission
- **THEN** the permission purpose string SHALL explain that Sift records the user's voice check-in
- **THEN** the permission purpose string SHALL explain that the recording is used for on-device transcription
- **THEN** the permission purpose string SHALL NOT describe the recording as a voice sample or speech-to-text evaluation

#### Scenario: Build metadata is explicit
- **WHEN** the app is prepared for TestFlight upload
- **THEN** the app target SHALL have explicit marketing version and current project version values
- **THEN** the release operator SHALL be able to bump the current project version before subsequent uploads

### Requirement: External TestFlight prep is documented

The beta readiness backlog SHALL distinguish codebase preparation from manual App Store Connect and device tasks needed for external TestFlight distribution.

#### Scenario: Manual Gemini key check is listed
- **WHEN** the release operator follows the beta operations checklist
- **THEN** the checklist SHALL remind them to verify the uploaded build has a working Gemini API key configured rather than the safe placeholder
- **THEN** the checklist SHALL NOT ask them to commit a real Gemini API key
- **THEN** the checklist SHALL state that a separate beta key is optional for the trusted beta

#### Scenario: Manual device smoke test is listed
- **WHEN** the release operator follows the beta operations checklist
- **THEN** the checklist SHALL include installing the TestFlight build on a personal device
- **THEN** the checklist SHALL include testing record, transcription, suggestions, practice selection, reflection, and history

#### Scenario: TestFlight review notes are listed
- **WHEN** the release operator follows the beta operations checklist
- **THEN** the checklist SHALL include preparing beta review notes that explain the reviewer path
- **THEN** the checklist SHALL include the wellness boundary that Sift is not therapy, medical advice, diagnosis, or crisis support
