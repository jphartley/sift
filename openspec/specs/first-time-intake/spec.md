## Purpose
Define how Sift presents a skippable first-time intake before the user's first voice check-in, captures voice-plus-chip responses across primary and optional deeper-tuning prompts, and analyzes responses into a persisted user practice profile that distinguishes hard constraints from soft recommendation priors.

## Requirements

### Requirement: System presents a skippable first-time intake before the first check-in
The system SHALL present a first-time intake before the user's first voice check-in on a clean install. The intake SHALL briefly introduce Sift as a voice check-in companion that works better when it knows what helps, what does not help, and what language or practice boundaries to respect. The intake SHALL allow the user to skip without blocking access to the core voice check-in loop.

#### Scenario: New user starts the app before completing intake
- **WHEN** the app launches and no intake completion state exists
- **THEN** the system SHALL present the first-time intake entry flow before the first check-in recording UI
- **THEN** the system SHALL explain the purpose of intake in plain, brief product language

#### Scenario: User skips intake
- **WHEN** the user chooses to skip intake
- **THEN** the system SHALL mark intake as skipped or incomplete
- **THEN** the system SHALL allow the user to start the first voice check-in

#### Scenario: User has already completed or skipped intake
- **WHEN** the app launches after intake has been completed or skipped
- **THEN** the system SHALL not require the first-time intake before showing the check-in flow

### Requirement: Intake captures three primary voice-first prompts
The system SHALL ask no more than three primary intake prompts before offering the optional deeper tuning branch. Each primary prompt SHALL support structured chip selections and an optional voice answer. The three primary prompts SHALL capture desired support, prior practice experience and fit, and boundaries or preferences Sift should respect.

#### Scenario: User answers desired support prompt
- **WHEN** the user reaches the desired support prompt
- **THEN** the system SHALL offer structured choices such as calming down, feeling less overwhelmed, processing emotions, getting unstuck, being kinder to myself, finding focus, sleeping better, making sense of things, and building a regular practice
- **THEN** the system SHALL allow the user to add a voice answer for nuance

#### Scenario: User answers prior practice prompt
- **WHEN** the user reaches the prior practice prompt
- **THEN** the system SHALL offer structured choices for practice families such as meditation, breathwork, journaling, yoga or movement, grounding, self-compassion, prayer or spiritual practice, creative practices, and little or no prior practice
- **THEN** the system SHALL capture whether selected practice families worked for the user, helped sometimes, did not really help, or should be avoided when the user provides that signal
- **THEN** the system SHALL allow the user to add a voice answer for nuance

#### Scenario: User answers boundaries prompt
- **WHEN** the user reaches the boundaries and preferences prompt
- **THEN** the system SHALL offer structured choices for boundaries and preferences such as secular-only language, openness to spiritual language, research-backed-only practices, body-focused practice avoidance, closed-eye practice avoidance, short practices, practical guidance, and no preference
- **THEN** the system SHALL allow the user to add a voice answer describing anything Sift should avoid

### Requirement: Per-practice sentiment selection uses a bottom-sheet picker
The prior practice prompt SHALL capture sentiment for each selected practice family through a bottom-sheet picker rather than inline chip rows. Selecting an unselected practice family chip SHALL select it and immediately present the sentiment picker. Sentiment SHALL remain optional, and selected practice families without an assigned sentiment SHALL be visually distinguished from those with an assigned sentiment.

#### Scenario: User selects a practice family for the first time
- **WHEN** the user taps an unselected practice family chip on the prior practice prompt
- **THEN** the system SHALL mark the practice family as selected
- **THEN** the system SHALL immediately present a bottom-sheet picker titled with the practice family name
- **THEN** the bottom-sheet SHALL offer the sentiment options "Worked for me", "Helped sometimes", "Didn’t really help", and "Please avoid"
- **THEN** the bottom-sheet SHALL offer a "Remove from selection" action

#### Scenario: User assigns a sentiment in the bottom sheet
- **WHEN** the user taps a sentiment option in the bottom sheet
- **THEN** the system SHALL associate the chosen sentiment with the practice family
- **THEN** the system SHALL dismiss the bottom sheet
- **THEN** the practice family chip SHALL be visually styled to indicate the assigned sentiment

#### Scenario: User taps an already-selected practice chip
- **WHEN** the user taps a practice family chip that is already selected
- **THEN** the system SHALL present the bottom-sheet picker for that practice family
- **THEN** the picker SHALL allow the user to change the sentiment, clear the sentiment, or remove the practice family from the selection

#### Scenario: User dismisses the bottom sheet without assigning a sentiment
- **WHEN** the user dismisses the bottom sheet without choosing a sentiment option
- **THEN** the practice family SHALL remain selected
- **THEN** the practice family chip SHALL be visually distinguished from chips with an assigned sentiment (for example, dashed outline with a lighter fill) to signal that sentiment is unset
- **THEN** the user SHALL be permitted to advance to the next prompt without assigning a sentiment

#### Scenario: User removes a practice family from the selection via the bottom sheet
- **WHEN** the user taps "Remove from selection" in the bottom sheet
- **THEN** the system SHALL deselect the practice family
- **THEN** the system SHALL clear any sentiment previously assigned to that practice family
- **THEN** the system SHALL dismiss the bottom sheet

### Requirement: Voice answer transcription gates intake navigation
While a voice answer transcription is in progress on any intake prompt, the system SHALL prevent the user from advancing to the next prompt. The system SHALL display an inline transcription progress indicator in the voice answer area. The system SHALL permit the user to skip the current prompt during transcription, which cancels any in-flight transcription. The system SHALL cancel any in-flight transcription when the user starts a new recording for the same prompt.

#### Scenario: User stops a voice recording
- **WHEN** the user stops a voice recording on any intake prompt
- **THEN** the system SHALL begin transcription of the recording
- **THEN** the system SHALL disable the Next action until transcription resolves
- **THEN** the system SHALL display an inline "Transcribing…" progress indicator in the voice answer area

#### Scenario: Transcription completes successfully
- **WHEN** transcription completes successfully
- **THEN** the system SHALL persist the resulting transcript to the intake response for the current prompt
- **THEN** the system SHALL re-enable the Next action
- **THEN** the system SHALL display the transcript in place of the in-progress indicator

#### Scenario: User skips while transcription is in progress
- **WHEN** the user taps Skip while a transcription is in progress
- **THEN** the system SHALL cancel the in-flight transcription
- **THEN** the system SHALL NOT persist a transcript for the current prompt
- **THEN** the system SHALL advance the intake flow according to skip behavior

#### Scenario: User re-records while transcription is in progress
- **WHEN** the user starts a new voice recording while a previous take for the same prompt is still transcribing
- **THEN** the system SHALL cancel the previous in-flight transcription
- **THEN** the system SHALL NOT persist a transcript from the cancelled take

#### Scenario: Transcription fails
- **WHEN** transcription fails for any reason after a recording is stopped
- **THEN** the system SHALL display an inline error message in the voice answer area offering re-record or continue
- **THEN** the system SHALL re-enable both Next and Skip actions
- **THEN** the system SHALL preserve all structured chip selections and other prompt state
- **WHEN** the user chooses to continue without a transcript
- **THEN** the system SHALL advance to the next prompt without persisting a transcript for the current prompt

### Requirement: Intake uses approved product language
The first-time intake SHALL use the approved product language for its introduction, primary prompts, optional deeper tuning prompt, optional prompts, chip labels, selected-item labels, action labels, and voice hints.

#### Scenario: Intake introduction is displayed
- **WHEN** the first-time intake introduction is shown
- **THEN** the system SHALL display "Before your first check-in, Sift will ask a few questions about you: what you are looking for, what you have tried, and what you want it to respect."
- **THEN** the system SHALL display "Tap the microphone to answer in your own words. This helps Sift understand you with more nuance, but you can also tap quick answers or skip anything."

#### Scenario: Desired support prompt is displayed
- **WHEN** the desired support prompt is shown
- **THEN** the system SHALL display "What are you hoping Sift can help you with?"
- **THEN** the system SHALL offer the choices "Calming down", "Feeling less overwhelmed", "Processing emotions", "Getting unstuck", "Being kinder to myself", "Finding focus", "Sleeping better", "Making sense of things", and "Building a regular practice"
- **THEN** the system SHALL display the voice hint "Tap the microphone if you want to give Sift a fuller picture."

#### Scenario: Prior practice prompt is displayed
- **WHEN** the prior practice prompt is shown
- **THEN** the system SHALL display "What have you tried before? What worked, and what didn’t?"
- **THEN** the system SHALL offer the choices "Meditation", "Breathwork", "Journaling", "Yoga or movement", "Grounding exercises", "Self-compassion", "Prayer or spiritual practice", "Creative practices", and "Nothing much yet"
- **THEN** the system SHALL offer selected-item labels "Worked for me", "Helped sometimes", "Didn’t really help", and "Please avoid"
- **THEN** the system SHALL display the voice hint "These are just starting points. Tap the microphone to tell Sift what you’ve tried, what worked, what didn’t, and what you want it to avoid."

#### Scenario: Boundaries prompt is displayed
- **WHEN** the boundaries and preferences prompt is shown
- **THEN** the system SHALL display "Is there anything you want Sift to respect or avoid?"
- **THEN** the system SHALL offer the choices "Secular only", "Spiritual language is okay", "Research-backed only", "No body-focused practices", "No closed-eye practices", "Keep practices short", "Keep it practical", and "No preference"
- **THEN** the system SHALL display the voice hint "Tap the microphone if there’s anything Sift should avoid or be careful with."

#### Scenario: Optional deeper tuning prompt is displayed
- **WHEN** the user finishes the primary intake prompts
- **THEN** the system SHALL display "That’s enough to get started. You can answer a few more to give Sift a fuller picture, or begin your first check-in now."
- **THEN** the system SHALL offer actions labeled "Answer a few more" and "Begin check-in"

#### Scenario: Optional experience prompt is displayed
- **WHEN** the optional experience prompt is shown
- **THEN** the system SHALL display "How much experience do you have with practices like mindfulness, yoga, journaling, or breathwork?"
- **THEN** the system SHALL offer the choices "None yet", "Beginner", "Some experience", "Regular practice", and "Experienced"

#### Scenario: Optional hard-moment support prompt is displayed
- **WHEN** the optional hard-moment support prompt is shown
- **THEN** the system SHALL display "When you are having a hard time, what tends to help?"
- **THEN** the system SHALL offer the choices "Stillness", "Movement", "Writing", "Talking to someone", "Sensory grounding", "Structure", "Self-compassion", and "A practical next step"

#### Scenario: Optional obstacles prompt is displayed
- **WHEN** the optional obstacles prompt is shown
- **THEN** the system SHALL display "What tends to get in the way when you try practices like this?"
- **THEN** the system SHALL offer the choices "Restlessness", "Overthinking", "Feeling numb", "Self-criticism", "Not enough time", "Sticking with it", "It can feel fake", and "Physical discomfort"

#### Scenario: Optional guidance style prompt is displayed
- **WHEN** the optional guidance style prompt is shown
- **THEN** the system SHALL display "What style of guidance feels best to you?"
- **THEN** the system SHALL offer the choices "Gentle", "Direct", "Practical", "Structured", "Brief", "Low-pressure", "Quirky", and "Spiritual"

### Requirement: Intake offers optional deeper tuning before the first check-in
After the three primary prompts, the system SHALL ask whether the user wants to answer a few more questions or start the first check-in. If the user chooses deeper tuning, the system SHALL ask additional optional questions before the first check-in. If the user declines, the system SHALL proceed to the first check-in.

#### Scenario: User declines deeper tuning
- **WHEN** the user completes or skips the three primary prompts and declines additional questions
- **THEN** the system SHALL proceed to the first check-in flow

#### Scenario: User accepts deeper tuning
- **WHEN** the user accepts additional questions
- **THEN** the system SHALL ask optional questions about practice experience level, what tends to work during hard moments, what gets in the way, and preferred coaching style
- **THEN** the system SHALL allow the user to proceed to the first check-in after the optional questions

### Requirement: System analyzes intake responses into a persisted practice profile
The system SHALL analyze structured chip selections and voice answers into a persisted user practice profile. The profile SHALL distinguish hard constraints from soft recommendation priors. The profile SHALL be available for future Gemini recommendation prompts and local recommendation validation.

#### Scenario: Intake analysis succeeds
- **WHEN** the user completes any intake responses and intake analysis succeeds
- **THEN** the system SHALL persist a user practice profile containing normalized constraints, priors, desired support areas, practice history signals, language preferences, evidence preference, and optional coaching style preferences
- **THEN** the system SHALL allow the user to continue to the first check-in

#### Scenario: Intake analysis receives skipped or empty answers
- **WHEN** the user skips all intake prompts or provides no usable intake answers
- **THEN** the system SHALL persist no restrictive constraints from intake
- **THEN** the system SHALL allow the user to continue to the first check-in

#### Scenario: Intake analysis fails
- **WHEN** intake analysis fails after the user has provided intake responses
- **THEN** the system SHALL show a recoverable error state
- **THEN** the system SHALL allow the user to retry analysis or continue to the first check-in without analyzed intake context

### Requirement: Intake profile preserves boundaries and priors separately
The persisted user practice profile SHALL encode hard constraints separately from soft priors. Hard constraints SHALL include explicit user boundaries such as secular-only language, research-backed-only practices, no prayer, explicitly avoided practice families, or other direct avoidance instructions. Soft priors SHALL include weaker signals such as helped-sometimes prior experience, preferred practice families, preferred tone, and typical obstacles.

#### Scenario: User selects secular-only language
- **WHEN** the user selects secular-only language during intake
- **THEN** the persisted profile SHALL include a hard constraint preventing religious, devotional, or prayer-like recommendations by default

#### Scenario: User says breathwork helped sometimes
- **WHEN** the user indicates breathwork helped sometimes or did not really help without explicitly banning it
- **THEN** the persisted profile SHALL include a soft prior that raises the threshold for recommending breathwork
- **THEN** the profile SHALL NOT treat breathwork as fully prohibited

#### Scenario: User explicitly asks Sift to avoid a practice family
- **WHEN** the user explicitly says Sift should not recommend a practice family
- **THEN** the persisted profile SHALL include a hard constraint excluding that practice family by default

### Requirement: Intake accepts mixed preferences without unnecessary exclusivity
The intake UI SHALL allow users to express mixed preferences without forcing them to resolve non-contradictory tension during intake. The system SHALL treat "No preference" as mutually exclusive with other boundary and preference choices. The system SHALL NOT treat combinations such as "Secular only" with "Spiritual language is okay", "Research-backed only" with "Spiritual language is okay", or "Keep it practical" with "Spiritual language is okay" as invalid.

#### Scenario: User selects no preference with another boundary choice
- **WHEN** the user selects "No preference" for the boundaries prompt
- **AND** the user has selected any other boundary or preference choice
- **THEN** the system SHALL clear the other selected boundary or preference choices or clear "No preference" when the user selects a specific choice

#### Scenario: User selects secular-only and spiritual language
- **WHEN** the user selects both "Secular only" and "Spiritual language is okay"
- **THEN** the system SHALL accept both selections
- **THEN** the persisted profile SHALL require secular framing while allowing spiritual or contemplative language that does not include religious doctrine, devotional framing, prayer, deity language, or tradition-dependent authority

#### Scenario: User selects research-backed only and spiritual language
- **WHEN** the user selects both "Research-backed only" and "Spiritual language is okay"
- **THEN** the system SHALL accept both selections
- **THEN** the persisted profile SHALL require explicit research grounding while allowing spiritual language only when the recommended practice remains eligible for research-backed-only users

#### Scenario: User selects practical and spiritual preferences
- **WHEN** the user selects both "Keep it practical" and "Spiritual language is okay"
- **THEN** the system SHALL accept both selections
- **THEN** the persisted profile SHALL prefer grounded, usable guidance while allowing spiritual language when it remains practical and relevant

#### Scenario: Voice answer creates ambiguity with selected chips
- **WHEN** the user's voice answer appears to soften, complicate, or conflict with selected chip choices
- **THEN** intake analysis SHALL preserve the stricter or safer interpretation for hard constraints unless the user clearly states an override
- **THEN** intake analysis SHALL preserve ambiguity as soft profile context when a hard constraint cannot be confidently inferred

### Requirement: First version defers profile review and later deepening
The first version SHALL not include a user-facing profile review or edit surface. The first version SHALL not resurface optional intake questions after the first check-in. These capabilities SHALL be tracked as future work outside this change.

#### Scenario: User completes intake
- **WHEN** the user completes the first-time intake
- **THEN** the system SHALL proceed without showing a profile review screen
- **THEN** the system SHALL not provide a settings-based profile editor as part of this change

#### Scenario: User declines optional deeper tuning
- **WHEN** the user declines optional deeper tuning before the first check-in
- **THEN** the system SHALL not resurface those optional questions later as part of this change
