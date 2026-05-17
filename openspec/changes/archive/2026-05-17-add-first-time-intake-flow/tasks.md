## 1. Profile Model And Storage

- [x] 1.1 Add a persisted user practice profile model or equivalent storage for intake completion state, hard constraints, soft priors, desired support areas, practice history signals, language preferences, evidence preference, and coaching style.
- [x] 1.2 Add storage access through injectable service or store boundaries that fit the existing SwiftData patterns.
- [x] 1.3 Add tests for default profile absence, skipped intake state, completed intake state, and persistence round-trip.

## 2. Practice Library Metadata

- [x] 2.1 Extend the Practice schema and YAML decoding to include evidence grounding metadata and boundary/preference matching metadata.
- [x] 2.2 Update bundled practices with explicit evidence eligibility and compact metadata for practice family, worldview/language framing, body-focused, closed-eye, breath-focused, devotional, and intensity characteristics where applicable.
- [x] 2.3 Update practice library tests to require unambiguous evidence metadata and matching metadata for every bundled practice.

## 3. Intake Capture And Analysis

- [x] 3.1 Add intake response models for structured chip selections and optional voice transcripts across the three primary prompts and optional deeper tuning prompts.
- [x] 3.2 Implement intake analysis that normalizes structured and voice responses into hard constraints and soft priors.
- [x] 3.3 Implement mixed-preference handling so only "No preference" is mutually exclusive, while tense combinations such as "Secular only" with "Spiritual language is okay" are preserved and interpreted conservatively.
- [x] 3.4 Add deterministic fake-backed tests for secular-only, research-backed-only, explicit practice-family avoidance, helped-sometimes prior experience, mixed preferences, skipped answers, and failed analysis.

## 4. Intake User Flow

- [x] 4.1 Add first-time intake entry before the first check-in on clean installs while allowing the user to skip.
- [x] 4.2 Build the three primary voice-first intake prompts with structured chips and optional voice response capture.
- [x] 4.3 Add the optional deeper tuning branch before the first check-in, with a decline path that proceeds immediately to the core check-in loop.
- [x] 4.4 Add tests for approved intake copy, chip labels, voice hints, and action labels.
- [x] 4.5 Add tests for first launch gating, skip behavior, completed intake behavior, optional branch acceptance, and optional branch decline.

## 5. Recommendation Integration

- [x] 5.1 Include the persisted intake profile in Gemini prompt construction when available, with hard constraints clearly separated from soft priors.
- [x] 5.2 Enforce local recommendation validation for hard constraints, including secular-only, research-backed-only, and explicitly excluded practice families.
- [x] 5.3 Apply soft priors to recommendation guidance without treating them as absolute exclusions.
- [x] 5.4 Add tests for prompt construction with and without profile context, local rejection of constraint-violating recommendations, research-backed-only validation, and clear current-check-in override behavior.

## 6. Backlog And Cleanup

- [x] 6.1 Capture future work for user profile review/editing and later resurfacing optional intake questions after the user has built trust with the core loop.
- [x] 6.2 Check whether AGENTS.md or docs need updates for new architecture, model storage, build/test workflow, or major product workflow changes.
- [x] 6.3 Run a scoped cleanup pass after implementation to remove dead code, unused imports, stale copy, and unnecessary abstraction.
- [x] 6.4 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` and the coverage summary command after implementation.

## 7. Feedback Fixes (Post-Implementation)

### B1: Per-practice sentiment bottom-sheet picker

- [x] 7.1 Replace the inline sentiment chip rows on the prior practice prompt with a bottom-sheet picker triggered by tapping a practice family chip.
- [x] 7.2 Open the bottom sheet immediately when an unselected chip is tapped, and reopen it when an already-selected chip is tapped.
- [x] 7.3 Render the bottom sheet with the practice family name as the title, four sentiment tiles ("Worked for me", "Helped sometimes", "Didn't really help", "Please avoid"), and a "Remove from selection" action.
- [x] 7.4 Auto-dismiss the bottom sheet on sentiment selection or remove action; allow dismissal without selection.
- [x] 7.5 Update practice chip visuals to show three states: unselected default, selected with sentiment (filled tint + sentiment icon), selected without sentiment (dashed outline with lighter fill).
- [x] 7.6 Update intake content tests and view-model tests to cover bottom-sheet open/dismiss/selection paths, removal, the three chip visual states, and the absence of inline chip rows.

### B2: Voice answer transcription gating

- [x] 7.7 Add an `isTranscribing` state to `IntakeViewModel` set true when `stopVoiceAnswer()` fires the transcription Task and reset on success, failure, or cancellation.
- [x] 7.8 Track the in-flight transcription Task on the view model so it can be cancelled.
- [x] 7.9 Disable the Next action in `IntakeScreen` while `isTranscribing` is true; keep Skip enabled and have it cancel any in-flight transcription before advancing.
- [x] 7.10 Cancel any in-flight transcription when the user starts a new recording for the same prompt, before starting the new recording.
- [x] 7.11 Display an inline "Transcribing…" progress indicator in the voice answer area while transcription is in progress.
- [x] 7.12 On transcription failure, display an inline error message offering re-record or continue; re-enable both Next and Skip; preserve chip selections and other prompt state.
- [x] 7.13 Update view-model tests to cover Next gating during transcription, Skip cancellation, re-record cancellation, success path, and failure path with continue-without-transcript.
