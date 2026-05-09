## Why

Internal beta users may hit permission, model, recording, transcription, network, or AI-service failures while trying to make vulnerable check-ins. Current recovery states are too generic and technical; they should calmly explain what happened, reduce blame, preserve user work where possible, and offer the next useful action.

## What Changes

- Add calm recovery presentation for microphone permission denial, including an "Open Settings" action because microphone access is required for Sift's core flow.
- Improve model download/loading failure recovery with a plain-language message and retry action.
- Improve empty or unusable speech recovery so users are invited to record again without feeling they did anything wrong.
- Improve analysis/network/API failure recovery so the transcript remains available and users can retry suggestions.
- Improve empty suggestion recovery so AI output failure does not feel like a user failure.
- Preserve existing successful check-in behavior while making failure states more specific and supportive.

## Capabilities

### New Capabilities

### Modified Capabilities

- `voice-check-in`: Replace generic check-in error handling with calm, action-specific recovery states, including opening app Settings for microphone permission denial.
- `automated-tests`: Add coverage expectations for the new recovery-state presentation and actions.

## Impact

- Affects `sift/ViewModels/RecordingViewModel.swift` state or presentation logic for recoverable check-in failures.
- Affects `sift/Views/RecordingScreen.swift` recovery UI and microphone Settings action.
- May add a small view-adjacent recovery presentation type to keep copy/actions testable.
- Affects unit tests for view model recovery behavior and view-adjacent copy/action presentation.
- May affect UI smoke tests if recovery states become directly testable there.
- No persistence model, Gemini API, WhisperKit dependency, or practice-library changes are expected.
