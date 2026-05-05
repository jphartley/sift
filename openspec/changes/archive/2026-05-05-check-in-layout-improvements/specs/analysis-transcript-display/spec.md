## ADDED Requirements

### Requirement: Transcript is displayed during analysis phase

The system SHALL display the user's transcribed text on screen during the analysis phase (after transcription completes and before Gemini recommendations arrive), providing visual feedback that the recording was captured.

#### Scenario: Transcript appears during analysis
- **WHEN** the system enters the analyzing state and a transcript is available
- **THEN** the transcript text SHALL be displayed on screen
- **THEN** a loading indicator SHALL remain visible to indicate analysis is in progress

#### Scenario: No transcript available during analysis
- **WHEN** the system enters the analyzing state but no transcript exists (e.g., transcription failed silently)
- **THEN** only the loading indicator SHALL be displayed
- **THEN** the app SHALL not crash or show an error for missing transcript text

### Requirement: Transcript appears with animation

The system SHALL animate the transcript's appearance during the analysis phase with a fade-in and slide-up transition after a brief delay, creating a sense of progression.

#### Scenario: Transcript animates in
- **WHEN** the analysis screen first appears
- **THEN** the transcript SHALL NOT be visible immediately
- **THEN** after a brief delay, the transcript SHALL become visible using a fade-in combined with a slide-up animation

#### Scenario: Animation does not block the analysis
- **WHEN** the transcript animation is playing
- **THEN** the Gemini analysis request SHALL proceed independently in the background
- **THEN** the analysis completion SHALL transition to the suggestion screen regardless of animation state
