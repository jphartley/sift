## ADDED Requirements

### Requirement: System preloads speech model at app launch

The system SHALL begin loading the WhisperKit speech model immediately upon app launch, before the user navigates to any tab. The model load SHALL run concurrently with UI rendering and SHALL NOT block the tab bar or history browsing.

#### Scenario: Model loads before user navigates to Check In
- **WHEN** the app launches and the user waits at least 5 seconds before tapping the Record tab
- **THEN** the transcription model SHALL already be in the `.ready` state

#### Scenario: Model still loading when user navigates to Check In
- **WHEN** the app launches and the user immediately taps the Record tab
- **THEN** the system SHALL display the loading state with current progress information from the ongoing model load

#### Scenario: Model load fails at launch
- **WHEN** the app launches and the model fails to download or compile
- **THEN** the system SHALL display an error message with a retry option when the user navigates to the Record tab

#### Scenario: App backgrounded during model load
- **WHEN** the app is backgrounded while the model is loading
- **THEN** on next foreground, the system SHALL continue or restart the model load

### Requirement: Model load is idempotent

The TranscriptionService `loadModel()` method SHALL be safe to call multiple times. If the model is already loaded or currently loading, subsequent calls SHALL return immediately without side effects.

#### Scenario: loadModel called when already ready
- **WHEN** `loadModel()` is called and the model is already in `.ready` state
- **THEN** the method SHALL return immediately without re-downloading or re-loading

#### Scenario: loadModel called when already downloading
- **WHEN** `loadModel()` is called and the model is already in `.downloading` state
- **THEN** the method SHALL return immediately without starting a second download

#### Scenario: loadModel called after previous failure
- **WHEN** `loadModel()` is called and the model is in `.failed` state
- **THEN** the method SHALL reset the state and attempt a fresh download and load
