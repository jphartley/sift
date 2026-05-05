## 1. Analysis transcript display

- [x] 1.1 Extract `AnalyzingView` struct from `RecordingScreen.analyzingView` into its own file/view, accepting `transcript: String` and `isTranscribing: Bool` parameters
- [x] 1.2 Add `@State private var showTranscript = false` with `.onAppear` animation trigger (0.4s delay, fade + slide-up)
- [x] 1.3 Wire `AnalyzingView(transcript: viewModel.lastTranscript)` into the `.analyzing` case in `RecordingScreen`

## 2. Suggestion view accordion and scroll

- [x] 2.1 Wrap `SuggestionView` body content in `ScrollView`
- [x] 2.2 Add `@State private var expandedID: String?` to `SuggestionView`
- [x] 2.3 Refactor `practiceCard(_:)` to show collapsed (name, badges, 2-line description, chevron) vs expanded (full description, full relevance, "Try This" button) based on `expandedID`
- [x] 2.4 Wire card tap to toggle `expandedID` (expand if collapsed, collapse if already expanded)
- [x] 2.5 Wire "Try This" button inside expanded card to call `onSelect(practice)`
- [x] 2.6 Set `NavigationStack` title display mode to `.inline` in `RecordingScreen`

## 3. Reflection view context and back navigation

- [x] 3.1 Add `Back` button to `ReflectionView.tryQuestion` phase (top-left, calls `onDismiss`)
- [x] 3.2 Ensure `Back` button is not visible in `reflectionForm` phase
- [x] 3.3 Add `practiceDescription: String` and `relevance: String` parameters to `ReflectionView`
- [x] 3.4 Display practice description and relevance above the "Did you try...?" question

## 4. ViewModel updates

- [x] 4.1 Extend `.reflecting` enum case to include `practiceDescription: String` and `relevance: String`
- [x] 4.2 Update `logPractice` to accept `Practice` and `relevance: String?`, derive all three values, set `.reflecting(practiceName:, practiceDescription:, relevance:)`
- [x] 4.3 Update all `switch` pattern matches on `RecordingState` to destructure the new associated values

## 5. Tests

- [x] 5.1 Update `RecordingStateTests` equality checks for `.reflecting` with new associated values
- [x] 5.2 Update `RecordingViewModelTests` to verify `logPractice` sets practice description and relevance in `.reflecting` state
- [x] 5.3 Update `RecordingViewModelTests` to verify `dismissPractice` correctly handles the updated state transitions
- [x] 5.4 Run full test suite (`xcodebuild test -skip-testing:siftUITests`) and fix any failures

## 6. Build verification

- [x] 6.1 Run `xcodebuild build` to verify the project compiles
- [x] 6.2 Remove any unused imports, dead code, or stale comments from modified files
