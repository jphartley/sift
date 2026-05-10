## 1. Setup Presentation

- [x] 1.1 Add view-adjacent first-time setup presentation data for downloading, local preparation, and waiting states.
- [x] 1.2 Update `RecordingScreen` loading UI to use calm first-time setup title, explanation, status copy, and first-run reassurance.
- [x] 1.3 Preserve determinate progress during model download.
- [x] 1.4 Preserve an active indeterminate loading state during local preparation.
- [x] 1.5 Avoid prototype-facing terms such as "speech model" in user-facing setup copy.

## 2. Responsive Microphone Startup

- [x] 2.1 Add a transient preparing-to-record state to the recording flow.
- [x] 2.2 Set preparing-to-record synchronously when the user taps the microphone from ready state.
- [x] 2.3 Render a "Getting microphone ready..." UI state that visibly acknowledges the tap and prevents duplicate taps.
- [x] 2.4 Ignore repeated recording-start requests while microphone permission or recorder startup is already pending.
- [x] 2.5 Preserve existing transitions to recording on success and microphone recovery on denial.

## 3. First-Launch Polish

- [x] 3.1 Create the Application Support directory before `ModelContainer` initialization.
- [x] 3.2 Keep the default SwiftData store location and schema unchanged.
- [x] 3.3 Add coverage or a static check that storage-directory preparation happens before `ModelContainer` initialization.

## 4. Tests

- [x] 4.1 Add Swift Testing coverage for setup copy explaining on-device speech recognition and first-time wait.
- [x] 4.2 Add coverage for download-phase progress presentation.
- [x] 4.3 Add coverage for local-preparation active loading presentation.
- [x] 4.4 Add view model coverage for immediate preparing-to-record transition.
- [x] 4.5 Add view model coverage that repeated recording-start taps while pending do not start overlapping recorder setup.
- [x] 4.6 Add coverage or static check for Application Support directory preparation.
- [x] 4.7 Confirm existing ready-screen orientation, microphone recovery, and SwiftData persistence tests still pass.

## 5. Verification

- [x] 5.1 Run focused setup/orientation and recording startup tests.
- [x] 5.2 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 5.3 Perform the scoped cleanup pass for dead code, unused imports, stale comments, and project-pattern alignment.
- [x] 5.4 Check whether `AGENTS.md` needs updates for this change.
- [x] 5.5 Run `openspec validate smooth-first-time-setup --strict`.
