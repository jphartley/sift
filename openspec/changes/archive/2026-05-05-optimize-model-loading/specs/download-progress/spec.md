## ADDED Requirements

### Requirement: System shows download progress during model download

The system SHALL display a determinate progress bar with a percentage value while the speech model is downloading. The progress SHALL be derived from the `Progress` callback provided by WhisperKit's download API.

#### Scenario: Download in progress
- **WHEN** the model is in the `.downloading` state
- **THEN** the system SHALL display a progress bar that fills from 0% to 100% based on `progress.fractionCompleted`
- **THEN** the system SHALL display the text "Downloading speech model..."

#### Scenario: Download complete
- **WHEN** the model transitions from `.downloading` to `.loading`
- **THEN** the progress bar SHALL be replaced by an indeterminate spinner with the text "Preparing speech model..."

#### Scenario: Download fails
- **WHEN** the model download encounters an error
- **THEN** the system SHALL transition to the `.failed` state and display the error message

### Requirement: System distinguishes download from compilation phases

The system SHALL display different UI depending on the model loading phase. The download phase SHALL show a progress bar. The compilation (prewarming/loading) phase SHALL show an indeterminate spinner.

#### Scenario: User sees distinct loading phases
- **WHEN** the model is downloading (first launch)
- **THEN** the user SHALL see a progress bar with percentage
- **THEN** the user SHALL see a spinner when the model is compiling/loading

#### Scenario: User sees only compilation on subsequent launches
- **WHEN** the model is already cached from a previous launch
- **THEN** the user SHALL see only the spinner (no download progress bar, since the cached model skips download)

### Requirement: ModelState enum includes download progress

The `ModelState` enum in `TranscriptionService.swift` SHALL include a `.downloading(progress: Double)` case where `progress` is a value between 0.0 and 1.0 representing the fraction of the download completed.

#### Scenario: ModelState reports download progress
- **WHEN** the model is downloading
- **THEN** `modelState` SHALL be `.downloading(progress:)` where progress increases from 0.0 toward 1.0

#### Scenario: ModelState reports ready after download
- **WHEN** download completes and model finishes loading
- **THEN** `modelState` SHALL be `.ready`
