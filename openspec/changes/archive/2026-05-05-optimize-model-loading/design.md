## Context

The WhisperKit model (`openai_whisper-base.en`, ~150 MB) is loaded lazily when the user navigates to the Check In tab. On first launch, this triggers a download from Hugging Face followed by Core ML model compilation. On subsequent launches, the cached model still requires compilation (~5-15 seconds depending on device). The user sees only a generic spinner during this wait.

```
Current:  App Launch ──► TabView ──► User taps "Record" ──► .task fires ──► loadModel() ──► wait ──► ready
                                                            (download + compile)
Proposed: App Launch ──► .task fires ──► loadModel() (background) ──► ready
                         │
                         └──► TabView ──► User taps "Record" ──► already ready (or shows progress)
```

**Project constraints**: iOS 26.4, Swift 6, `@Observable` observation, Single-Element Project `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, WhisperKit 0.18.0 via SPM. No comments policy.

## Goals / Non-Goals

**Goals:**
- Eliminate or significantly reduce perceived wait time when the user first navigates to the Check In tab
- Show download progress (percentage, bytes) instead of an indeterminate spinner during first-launch download
- Keep the implementation minimal — avoid over-engineering

**Non-Goals:**
- Bundling the model in the app binary (would increase app size by ~150 MB; better suited for a v2 optimization)
- Switching to a different model variant (tiny.en would be smaller but less accurate; the base.en choice is intentional)
- Background fetch / BGTaskScheduler prewarming (complex, iOS-restricted, not needed for MVP)
- Changing the recording/transcription workflow logic

## Decisions

### 1. Preload model at app launch in `siftApp.task`

Move `loadModel()` from `RecordingScreen.task` → `siftApp.body` `.task` modifier. The model starts downloading/loading immediately when the app launches, concurrent with UI rendering. The TabView is fully interactive during loading — the user can browse history while the model loads.

**Alternatives considered:**
- `init()` of siftApp: Not possible — `init()` cannot be async, and `WhisperKit(model:)` is async.
- `onAppear` of ContentView: Works but `.task` on siftApp is cleaner (scoped to app lifetime, cancelled on app termination).
- `BGTaskScheduler`: Overkill for MVP. iOS background tasks are unreliable and complex.

### 2. Two-phase model initialization with progress

Replace the single `WhisperKit(model:)` call with explicit download + local initialization:

```swift
let folder = try await WhisperKit.download(
    variant: "openai_whisper-base.en",
    progressCallback: { progress in
        self.modelState = .downloading(progress: progress.fractionCompleted)
    }
)
self.modelState = .loading
whisperKit = try await WhisperKit(modelFolder: folder.path, download: false)
self.modelState = .ready
```

This separates download (trackable with `Progress`) from Core ML compilation (indeterminate but fast on subsequent launches). The static `WhisperKit.download(variant:progressCallback:)` returns the local folder URL and accepts a `Progress` callback.

**Alternatives considered:**
- Use `WhisperKit(model:)` with `modelStateCallback`: The callback provides state transitions (`.downloading`, `.prewarming`, `.loading`, `.loaded`) but no byte-level progress. Less informative for the user during the long first-launch download.
- Single `WhisperKit(model:)` call with indeterminate spinner: Same as today, no improvement.

### 3. Make `loadModel()` idempotent

Since siftApp starts the load and RecordingScreen may also trigger it (on retry after failure), `loadModel()` must be safe to call multiple times. Add a guard at the top:

```swift
func loadModel() async {
    if case .downloading = modelState { return }
    if case .loading = modelState { return }
    if case .ready = modelState { return }
    modelState = .downloading(progress: 0)
    // ... download + init ...
}
```

### 4. Extend local `ModelState` enum

Expand from 4 cases to 5, with progress in `downloading`:

| Old | New |
|-----|-----|
| `.notLoaded` | Same — initial state |
| `.loading` | Now means "loading/compiling" (post-download phase) |
| — | `.downloading(progress: Double)` — download phase with 0.0-1.0 progress |
| `.ready` | Same |
| `.failed(String)` | Same |

### 5. Share TranscriptionService via SwiftUI environment

siftApp creates `@State var transcriptionService = TranscriptionService()`, injects via `.environment(transcriptionService)`. RecordingScreen reads via `@Environment(TranscriptionService.self)`. RecordingViewModel receives it through a new `configure(transcriptionService:)` parameter.

**Alternatives considered:**
- Singleton: Antipattern in SwiftUI, harder to test.
- Pass via init: RecordingViewModel is `@State`, can't receive init params with `@State`. Use `.configure()` pattern already established for `modelContext`.

### 6. RecordingScreen loading UI reads TranscriptionService.modelState

The loading view in RecordingScreen switches its display based on `transcriptionService.modelState`:
- `.downloading(let progress)` → progress bar with "Downloading speech model..."
- `.loading`, `.notLoaded` → spinner with "Preparing speech model..."
- `.ready` → proceed to mic permission → record button
- `.failed` → error with retry

The `RecordingViewModel.setup()` method no longer calls `loadModel()`. It only requests microphone permission and transitions to `.ready`. The `RecordingState.loadingModel` is retained for the brief mic permission window, but the loading UI overlays it with progress info from `transcriptionService.modelState`.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| **Network usage on every app launch**: Download only happens on first launch (WhisperKit caches to `~/Documents/huggingface/models/`). Subsequent launches skip download. | Two-phase init with `WhisperKit.download()` handles this — it checks cache before downloading. |
| **iOS may purge model cache under storage pressure**: The model cache lives in Documents, which is backed up and less likely to be purged than Caches. But it could happen. | On cache miss, the app re-downloads with progress indicator. No worse than today. If this becomes common, consider moving to a non-purgeable location or bundling. |
| **Increased app launch memory usage**: The model loads earlier, using memory sooner (~150 MB peak during compilation, less after). | This is the tradeoff for faster Check In. The memory would be used anyway when the user navigates to Record. Acceptable for the MVP — if memory pressure becomes an issue, we can add `unloadModels()` after inactivity. |
| **siftApp.task cancellation**: If the app is backgrounded during download, the task is cancelled. | WhisperKit's download uses URLSession which supports background downloads. We can set `useBackgroundDownloadSession: true` in a follow-up. For now, on re-launch, `loadModel()` re-checks cache and resumes. |
| **RecordingViewModel.setup() no longer loads model**: If siftApp's `.task` fails silently, RecordingScreen shows loading forever. | `RecordingViewModel.setup()` checks `transcriptionService.modelState` and transitions to `.error` if `.failed`. The error view has a retry button that calls `transcriptionService.loadModel()` directly. |
