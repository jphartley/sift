## Why

The check-in flow has two UX gaps that undermine user confidence and usability. During the 5-10 second analysis phase, users see only a spinner with no feedback that their recording was captured, leading to uncertainty about whether the system is working. Once analysis completes, the suggestion screen crams three dense sections (transcript, rationale, practice cards) into a non-scrollable view with truncated text and an immediate-commit tap pattern that prevents users from reading practice details before deciding to try one.

## What Changes

- **Analysis screen shows transcript**: After transcription completes, the transcript appears with a fade-in animation during the Gemini analysis wait, giving users immediate validation that their recording was captured.
- **Suggestion screen uses ScrollView**: Content is no longer clipped; users can scroll through all sections naturally.
- **Practice cards use accordion pattern**: Tapping a card expands it inline to show the full description and Gemini's relevance text (no line limits). A separate "Try This" button inside the expanded card commits the user to trying that practice. Only one card expands at a time.
- **Reflection screen shows practice context**: The "Did you try X?" screen now includes the full practice description and Gemini's relevance explanation, so users can re-read what they committed to before rating.
- **Back navigation from reflection**: A "Back" button on the reflection screen's first phase lets users return to the suggestion view if they tapped the wrong practice card.
- **Navigation title uses inline mode**: Reduces vertical space consumed by the "Check In" title, preventing overlap with content.

## Capabilities

### New Capabilities
- `suggestion-interaction`: The suggestion screen shall present practice cards as expandable accordion items with full readable content and a distinct commit action, supporting informed practice selection.
- `analysis-transcript-display`: The analysis phase shall display the user's transcript with an animated appearance, providing feedback that the recording was processed before recommendations appear.

### Modified Capabilities
- None. Existing spec-level requirements for recording, practice logging, and reflection remain unchanged; the changes are UI presentation and interaction refinements.

## Impact

- **Views**: `RecordingScreen.swift` (extract `AnalyzingView`, inline nav title), `SuggestionView.swift` (ScrollView, accordion, "Try This" button), `ReflectionView.swift` (practice context display, back button)
- **ViewModel**: `RecordingViewModel.swift` (extend `logPractice` to capture practice description and relevance, pass to `.reflecting` state)
- **Tests**: `RecordingStateTests.swift` (updated `.reflecting` case equality), `RecordingViewModelTests.swift` (verify practice details flow into `.reflecting`)
- No API changes, no new dependencies
