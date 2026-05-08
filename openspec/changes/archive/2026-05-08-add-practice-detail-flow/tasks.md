## 1. State Flow

- [x] 1.1 Add a practice detail state between suggesting and reflecting.
- [x] 1.2 Change suggestion selection so "Try This" opens practice detail without creating a PracticeAttempt.
- [x] 1.3 Add an "I did this" action that creates the PracticeAttempt and transitions to reflection.
- [x] 1.4 Preserve back navigation from practice detail to suggestions without logging an attempt.

## 2. Practice Detail UI

- [x] 2.1 Create a practice detail view for selected recommended practices.
- [x] 2.2 Render practice name, category, duration, Gemini relevance, summary, numbered steps, and why-it-helps text.
- [x] 2.3 Use "One way to practice" as the steps section heading.
- [x] 2.4 Add a sticky, always-enabled "I did this" bottom action that respects the safe area.
- [x] 2.5 Show a subtle non-red safety note when `avoidWhen` is non-empty or intensity is high.
- [x] 2.6 Omit labels, keywords, best-for values, and low/medium intensity from the practice detail UI.

## 3. Reflection UI

- [x] 3.1 Remove the "Did you try it?" confirmation phase from reflection.
- [x] 3.2 Simplify reflection to show minimal practice context, helpfulness controls, optional notes, Skip, and Save.
- [x] 3.3 Ensure skipping reflection still persists the completed PracticeAttempt with nil helpfulness.

## 4. Tests and Verification

- [x] 4.1 Update RecordingState equality tests for the new practice detail state.
- [x] 4.2 Update RecordingViewModel tests for select, back, completion, and reflection persistence semantics.
- [x] 4.3 Add or update view tests/UI smoke coverage where existing test patterns allow.
- [x] 4.4 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 4.5 Complete a scoped cleanup pass and check whether `AGENTS.md` needs further updates.
