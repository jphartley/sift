## Why

The WhisperKit model takes a long time to become available after the app starts — on first launch it downloads ~150 MB from Hugging Face, and on subsequent launches it re-compiles Core ML models. Currently the loading only begins when the user navigates to the Check In tab, creating a frustrating wait with only a generic spinner. Preloading the model at app launch and showing download progress will eliminate or significantly reduce perceived wait time.

## What Changes

- **Preload model at app launch**: Move WhisperKit initialization from `RecordingScreen.task` to `siftApp.task`, so the model starts downloading/loading immediately — by the time the user navigates to the Check In tab, the model is already ready (or nearly so).
- **Show download progress**: Replace the generic "Loading speech model..." spinner with a progress bar (percentage and bytes) during the initial download phase, using WhisperKit's `progressCallback` API and `modelStateCallback`.
- **Add model load timing**: Track and log model load duration for diagnostics, stored on the Session model or logged to console.
- **Use `modelStateCallback` for finer state tracking**: Replace the current binary `.notLoaded`/`.loading`/`.ready`/`.failed` wrapper with real-time state observation from WhisperKit's own `ModelState` (`.unloaded`, `.downloading`, `.downloaded`, `.prewarming`, `.prewarmed`, `.loading`, `.loaded`).

## Capabilities

### New Capabilities

- `model-preloading`: The system SHALL begin loading the WhisperKit model at app launch (in `siftApp.task`) rather than when the Check In tab first appears. The model load SHALL run concurrently with the UI and not block the tab bar or history browsing.
- `download-progress`: The system SHALL display a progress bar with percentage and byte counts during model download, replacing the indeterminate spinner. The system SHALL show distinct UI for download vs. compilation phases.

### Modified Capabilities

- `voice-check-in`: The "First launch loads WhisperKit model" scenario is expanded — loading begins at app launch instead of on first tab navigation. The loading UI moves from `RecordingScreen` to `ContentView` (or a shared overlay). The RecordingScreen's `.idle` and `.loadingModel` states are updated to reflect shareable loading state from the preloaded service.

## Impact

- `siftApp.swift` — add `.task` modifier to preload model
- `TranscriptionService.swift` — refactor to support progress callbacks, expose WhisperKit `ModelState`, two-phase init (download first, then prewarm/load)
- `RecordingViewModel.swift` — remove `setup()` model loading; instead observe shared TranscriptionService state
- `RecordingScreen.swift` — remove loading UI (moved to ContentView), simplify state machine
- `ContentView.swift` — add loading overlay/progress bar that observes TranscriptionService model state
- Tests — `TranscriptionServiceTests`, `RecordingViewModelTests`, and `RecordingStateTests` will need updates
