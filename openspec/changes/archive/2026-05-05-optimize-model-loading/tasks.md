## 1. TranscriptionService — ModelState and loadModel refactor

- [x] 1.1 Expand `ModelState` enum: add `.downloading(progress: Double)` case between `.notLoaded` and `.loading`
- [x] 1.2 Refactor `loadModel()` to use explicit `WhisperKit.download(variant:progressCallback:)` followed by `WhisperKit(modelFolder:download:false)`
- [x] 1.3 Make `loadModel()` idempotent: guard-return early if already `.downloading`, `.loading`, or `.ready`
- [x] 1.4 Wire `progressCallback` to update `modelState = .downloading(progress.fractionCompleted)` on the download step
- [x] 1.5 Set `modelState = .loading` during the init/prewarm phase, `.ready` on success, `.failed` on error

## 2. TranscriptionService tests

- [x] 2.1 Update `ModelState` equality tests to cover `.downloading(progress:)` case
- [x] 2.2 Add test: idempotent loadModel returns immediately when already `.downloading`
- [x] 2.3 Add test: idempotent loadModel returns immediately when already `.ready`
- [x] 2.4 Add test: `.downloading` progress values with different fractions are not equal

## 3. siftApp — preload at launch

- [x] 3.1 Add `import WhisperKit` to siftApp.swift
- [x] 3.2 Create `@State private var transcriptionService = TranscriptionService()` in siftApp
- [x] 3.3 Add `.task { await transcriptionService.loadModel() }` to WindowGroup content
- [x] 3.4 Inject transcriptionService via `.environment(transcriptionService)` on ContentView

## 4. RecordingScreen / RecordingViewModel — consume shared service

- [x] 4.1 Add `@Environment(TranscriptionService.self) private var transcriptionService` to RecordingScreen
- [x] 4.2 Update `RecordingViewModel.configure()` to accept `TranscriptionService` parameter, store it
- [x] 4.3 Update `RecordingViewModel.setup()`: remove `transcriptionService.loadModel()` call, keep mic permission request, transition to `.ready` after permission granted
- [x] 4.4 Update RecordingScreen.loadingView to show progress bar when `transcriptionService.modelState == .downloading(let progress)`, spinner otherwise
- [x] 4.5 Update errorView \"Retry\" button to call `transcriptionService.loadModel()` instead of `viewModel.setup()`

## 5. ViewModel tests

- [x] 5.1 Update `RecordingViewModelTests` to inject a mock/stub TranscriptionService or accept the new configure parameter
- [x] 5.2 Verify setup() no longer triggers model load (can be checked by observing no state change in TranscriptionService)

## 6. Build, test, and cleanup

- [x] 6.1 Run `xcodebuild test` (unit+integration, skip UI) and fix failures
- [x] 6.2 Manual smoke test: first launch (download + progress bar), subsequent launch (fast load)
- [x] 6.3 Check for dead code or unused imports introduced by these changes
