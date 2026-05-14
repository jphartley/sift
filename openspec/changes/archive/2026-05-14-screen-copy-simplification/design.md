## Context

All changes are confined to SwiftUI view layer — no data model, service, or API changes. The affected files are:

- `sift/Views/RecordingScreen.swift` — loading view, ready/check-in view, recording view
- `sift/Views/AnalyzingView.swift` — analyzing view
- `sift/Views/SuggestionView.swift` — results/suggestion view
- `sift/Views/ReflectionView.swift` — reflection/after view

## Goals / Non-Goals

**Goals:**
- Remove redundant labels and copy across all six screen states
- Improve visual hierarchy on the results screen (transcript secondary, rationale primary)
- Replace misleading dashed-border prompt hints with a plain "For example:" list
- Replace the "Done · maybe later" button with clearly active "I'm good for now" styling

**Non-Goals:**
- No logic, state, navigation, or data model changes
- No changes to the returning-user ("Check in again") variant of the ready screen
- No animation or layout restructuring beyond removing elements

## Decisions

**Loading screen — remove `message` from view only, keep in model**
The `RecordingScreenSetup.Presentation` struct has a `message` field. Remove the `Text(presentation.message)` call from `loadingView` but leave the struct intact to avoid breaking test coverage on the presentation logic.

**Check-in screen — merge `reassurance` + `nextStep` into single string**
`RecordingScreenOrientation.reassurance` becomes the combined shortened copy. `nextStep` is removed from the enum and the view. The view currently renders both separately; after the change it renders only `reassurance`.

New copy: *"Speak for about a minute about what feels most alive right now, what happened, how it feels, or what kind of support you want. Sift will reflect back what it heard and suggest a few practices to choose from."*

**Check-in screen — replace `starterPromptsView` overlay style with plain italic list**
Current: `ForEach` inside a dashed-border `RoundedRectangle` overlay — looks tappable.
New: A `VStack` with a "For example:" caption label followed by the three prompts as plain italic body text. No borders, no backgrounds, no tap targets.

**Recording screen — remove three elements, keep one**
Remove: `Text("LISTENING")`, `Text("I'm here.")`, `Text("Reading on this phone only.")` and their layout containers. Keep `Text("Take your time.")` as a single-line display text.

**Analyzing screen — remove subtitle only**
Remove the `Text("A moment of quiet while I take it in.")` line and the enclosing `VStack(spacing: 10)` wrapper (reduce to just the title text directly).

**Results screen — three changes**
1. Remove `memoryInsertCard` and the `if hasPriorSessions { memoryInsertCard }` conditional entirely. Also remove `SuggestionViewContent.memoryHeading`.
2. Invert transcript/rationale prominence: transcript text drops to `SiftColor.quiet` (from `SiftColor.ink`), rationale heading promotes to `SiftFont.heading` (from eyebrow) and rationale text promotes to `SiftColor.ink` (from `SiftColor.muted`).
3. Change `doneButtonTitle` to `"I'm good for now"` and swap from `GhostButtonStyle` to a secondary style with visible border so it reads as active. Use `SecondaryButtonStyle` if it exists, otherwise apply explicit `.overlay(Capsule().strokeBorder(...))` styling inline.

**Reflection screen — two small copy changes**
Remove `Text("AFTER")` and its padding. Update TextField placeholder string.

## Risks / Trade-offs

- [Removing `memoryInsertCard`] The `hasPriorSessions` parameter on `SuggestionView` becomes unused. Leave it in the signature for now to avoid cascading changes to call sites; it can be cleaned up separately.
- [Button style] If `SecondaryButtonStyle` doesn't exist in the design system, we'll style inline rather than introduce a new reusable style.
