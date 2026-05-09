# privacy-trust Specification

## Purpose
TBD - created by archiving change add-privacy-trust-tab. Update Purpose after archive.
## Requirements
### Requirement: App provides a first-class Privacy tab

The system SHALL provide a top-level Privacy tab that presents plain-language privacy and trust information for Sift users.

#### Scenario: Privacy tab is visible
- **WHEN** the app shows its main tab interface
- **THEN** the system SHALL show a tab labeled "Privacy"
- **THEN** the tab SHALL NOT be labeled "Gemini" or "LLM"

#### Scenario: Privacy tab opens privacy content
- **WHEN** the user selects the Privacy tab
- **THEN** the system SHALL display a privacy screen with the title "Privacy"
- **THEN** the system SHALL display content in a vertically scrollable layout

### Requirement: Privacy screen explains Sift in plain language

The system SHALL introduce Sift and its creator in simple language before explaining data handling.

#### Scenario: Privacy intro is displayed
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL show "Sift is a small passion project by Jeremy Hartley."
- **THEN** the system SHALL show "It is built to help people turn voice check-ins into practical wellness suggestions."

### Requirement: Privacy screen explains recording data flow

The system SHALL explain what happens to audio, transcripts, AI suggestions, history, and deletion in concrete plain language.

#### Scenario: Audio handling is explained
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL explain that the user's voice stays on the phone
- **THEN** the system SHALL explain that Sift records audio on the device and transcribes it on the device
- **THEN** the system SHALL explain that the temporary audio file is deleted after transcription
- **THEN** the system SHALL explain that audio is not sent to Gemini

#### Scenario: Transcript handling is explained
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL explain that transcript text is sent for AI suggestions
- **THEN** the system SHALL explain that Sift sends text, not audio, to Gemini
- **THEN** the system SHALL explain that recent check-in text and practice helpfulness history may be included to make suggestions more useful

#### Scenario: Local history handling is explained
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL explain that check-ins and practice reflections are saved locally in the app
- **THEN** the system SHALL explain that users can delete check-ins from History

### Requirement: Privacy screen explains developer access

The system SHALL explain what Jeremy can and cannot see using plain language that matches the current no-backend architecture.

#### Scenario: Developer access limits are explained
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL explain that Sift does not have a server where check-ins are stored
- **THEN** the system SHALL explain that Jeremy cannot browse the user's recordings, transcripts, or history
- **THEN** the system SHALL explain that if the user emails feedback, Jeremy will only see what the user chooses to send

### Requirement: Privacy screen explains AI suggestions accurately

The system SHALL explain Gemini usage in the body copy without making stronger anonymity or provider-retention claims than the implementation and paid Gemini API policy support.

#### Scenario: Gemini request identity is explained
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL explain that Sift sends text to Gemini using Sift's developer API key
- **THEN** the system SHALL explain that Sift does not attach the user's name, email, or account to Gemini requests
- **THEN** the system SHALL explain that identifying details spoken in a check-in remain part of the transcript sent to Gemini

#### Scenario: Paid Gemini API data use is explained
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL explain that Google says paid Gemini API prompts and responses are not used to improve Google products
- **THEN** the system SHALL explain that requests may be temporarily retained for service, safety, and abuse-prevention purposes

### Requirement: Privacy screen includes Safety and Questions sections

The system SHALL include Safety and Questions sections inside the Privacy tab so users know where emotional-safety and contact information belong.

#### Scenario: Safety section is visible
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL show a "Safety" section inside the Privacy tab
- **THEN** the Safety section SHALL state that Sift is for reflection and practice suggestions
- **THEN** the Safety section SHALL state that Sift is not a therapist, doctor, or crisis service

#### Scenario: Safety section supports user agency
- **WHEN** the Privacy screen is displayed
- **THEN** the Safety section SHALL tell users they can pause, skip, adapt, or stop a practice
- **THEN** the Safety section SHALL suggest gentle next steps such as putting the phone down, feeling their feet, taking a breath, or reaching out to someone they trust

#### Scenario: Safety section gives urgent support guidance
- **WHEN** the Privacy screen is displayed
- **THEN** the Safety section SHALL tell users to contact emergency support or a trusted person right away if they feel at risk of hurting themselves or someone else
- **THEN** the Safety section SHALL tell users to contact emergency support or a trusted person right away if they do not feel safe

#### Scenario: Questions section is visible
- **WHEN** the Privacy screen is displayed
- **THEN** the system SHALL show "Sift is made by Jeremy Hartley."
- **THEN** the system SHALL show "Contact: jphartley@gmail.com"
- **THEN** the system SHALL show "Last updated: May 2026"

### Requirement: Developer logs avoid sensitive check-in content

The system SHALL NOT print user transcript text, full Gemini prompt text, or Gemini response text to the developer console during the recommendation flow.

#### Scenario: Gemini request logging omits sensitive text
- **WHEN** the app sends a Gemini recommendation request
- **THEN** any developer console logs SHALL NOT include the user's transcript text
- **THEN** any developer console logs SHALL NOT include the full prompt text

#### Scenario: Gemini response logging omits sensitive text
- **WHEN** Gemini returns a success or error response
- **THEN** any developer console logs SHALL NOT include raw Gemini response text
- **THEN** logs MAY include non-sensitive metadata such as model name, prompt length, history count, confidence, escalation state, and practice IDs

