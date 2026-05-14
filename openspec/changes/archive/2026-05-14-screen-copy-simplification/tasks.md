## 1. Loading Screen (RecordingScreen.swift — loadingView)

- [x] 1.1 Remove `Text(presentation.message)` and its enclosing `VStack(spacing: 12)` wrapper from `loadingView`, keeping only `Text(presentation.title)` in that block

## 2. Check-in Ready Screen (RecordingScreen.swift — readyView + orientation copy)

- [x] 2.1 Remove the `Text(eyebrowDateString())` block (and its `.padding(.bottom, 16)`) from `readyView`
- [x] 2.2 Update `RecordingScreenOrientation.reassurance` to: `"Speak for about a minute about what feels most alive right now, what happened, how it feels, or what kind of support you want. Sift will reflect back what it heard and suggest a few practices to choose from."`
- [x] 2.3 Remove `RecordingScreenOrientation.nextStep` from the enum and remove its `Text(RecordingScreenOrientation.nextStep)` render call in `readyView`
- [x] 2.4 Replace `starterPromptsView` body: remove the dashed-border overlay; render a `Text("For example:")` caption label followed by the three prompts as plain `.italic()` body text in a `VStack`

## 3. Recording Screen (RecordingScreen.swift — recordingView)

- [x] 3.1 Remove the `Text("LISTENING")` label and its `.padding(.bottom, 16)` from `recordingView`
- [x] 3.2 Remove `Text("I'm here.")` — keep only `Text("Take your time.")` as a single line (remove the `VStack(alignment: .leading, spacing: 2)` wrapper, replace with the single text)
- [x] 3.3 Remove `Text("Reading on this phone only.")` and the outer `VStack(spacing: 16)` that wraps Stop + privacy note (replace with just the Stop `Button` directly)

## 4. Analyzing Screen (AnalyzingView.swift)

- [x] 4.1 Remove `Text("A moment of quiet while I take it in.")` and collapse the `VStack(spacing: 10)` wrapper to just `Text("Reading what you shared")` inline

## 5. Results / Suggestion Screen (SuggestionView.swift)

- [x] 5.1 Remove `SuggestionViewContent.memoryHeading` constant and the `memoryInsertCard` computed property
- [x] 5.2 Remove `if hasPriorSessions { memoryInsertCard }` from `body`
- [x] 5.3 In `transcriptSection`: change transcript `Text` foreground from `SiftColor.ink` to `SiftColor.quiet`
- [x] 5.4 In `transcriptSection`: change rationale heading `Text` font from `SiftFont.eyebrow` to `SiftFont.heading` and foreground from `SiftColor.quiet` to `SiftColor.ink`; change rationale body `Text` foreground from `SiftColor.muted` to `SiftColor.ink`
- [x] 5.5 Change `SuggestionViewContent.doneButtonTitle` to `"I'm good for now"`
- [x] 5.6 Change the done button style from `GhostButtonStyle()` to `PrimaryButtonStyle(soft: true)`

## 6. Reflection Screen (ReflectionView.swift)

- [x] 6.1 Remove the `Text("AFTER")` block (and its tracking/eyebrow styling) and the enclosing `VStack(alignment: .leading, spacing: 8)` wrapper — keep only `Text("How did that land?")`
- [x] 6.2 Update the `TextField` placeholder from `"(optional) anything else you want to mark…"` to `"(Optional) anything else you want to share..."`

## 7. Test Updates

- [x] 7.1 Update `RecordingScreenOrientationTests` — any assertions referencing removed copy (`nextStep`, timestamp label, "LISTENING", "I'm here.", "Reading on this phone only.", "no right or wrong") should be updated or removed to reflect the new copy
