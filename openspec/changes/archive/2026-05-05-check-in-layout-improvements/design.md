## Context

The current check-in flow has three screens that create usability friction:

1. **Analysis wait** (`RecordingScreen.analyzingView`): A bare spinner with no transcript feedback. The user just recorded their voice but sees no evidence the system captured it during the 5-10 second Gemini wait.

2. **Suggestion screen** (`SuggestionView`): A plain `VStack` (no `ScrollView`) with `.lineLimit(2)` on practice descriptions and `.lineLimit(3)` on relevance text. The entire practice card is a `Button` — one tap immediately commits to trying a practice with no opportunity to read its full description first.

3. **Reflection screen** (`ReflectionView`): Shows only the practice name ("Did you try Box Breathing?"). The user cannot re-read the practice description or Gemini's relevance explanation to remember what they committed to.

These are not spec-level behavioral changes — the recording state machine, Gemini integration, and data model remain unchanged. The change is purely UI presentation and interaction refinements within the existing architecture.

## Goals / Non-Goals

**Goals:**
- Show the user's transcript during the analysis wait phase with an animated appearance
- Make the suggestion screen scrollable so no content is clipped
- Allow users to read full practice descriptions and relevance text before committing to try one (accordion pattern: tap to expand, separate "Try This" button)
- Show practice context (description + relevance) on the reflection screen so users can re-read before rating
- Provide a clear "Back" escape from the reflection screen's first phase for accidental card taps
- Use inline navigation title to reclaim vertical space

**Non-Goals:**
- Changing the `RecordingState` enum structure (`.reflecting` gains associated values but the state machine logic is unchanged)
- Modifying Gemini integration, prompt construction, or model routing
- Adding new screens or navigation destinations
- Changing the practice library data or `Practice` struct
- Persistence behavior changes (session/attempt saving unchanged)
- Adding animations beyond the analysis transcript fade-in

## Decisions

### Decision 1: Accordion pattern for practice cards

**Chosen**: Inline accordion — one card expanded at a time, tapping a collapsed card expands it, tapping the expanded card collapses it. A "Try This" button inside the expanded card triggers the commit.

**Alternatives considered**:
- *Always-expanded full scroll*: Simpler code but makes the page very long; users must scroll past all content to compare options. The collapsed preview provides a scannable "menu."
- *Detail sheet on tap*: Gives focused reading space but adds a context-switching modal step; feels disconnected from the browsing flow.

**Implementation**: A `@State private var expandedID: String?` property in `SuggestionView` tracks which card (by practice ID) is open. The `practiceCard` helper reads this state to conditionally show full content and the "Try This" button. Only one card can be expanded; tapping a different card collapses the previous one.

### Decision 2: Transcript animation during analysis

**Chosen**: Fade-in combined with slide-up (`opacity` + `move(edge: .bottom)`) triggered after a 0.4-second delay via `.onAppear`.

**Alternatives considered**:
- *Typewriter effect*: Visually appealing but complex to implement well and jarring if analysis completes mid-animation.
- *Static display (no animation)*: Adequate but misses the "progression feel" the user wants.

**Implementation**: A new `AnalyzingView` struct (extracted from `RecordingScreen`) with `@State private var showTranscript = false`. On `.onAppear`, a `withAnimation` block sets it to `true` after a 0.4s delay. The transcript text view uses `.transition(.opacity.combined(with: .move(edge: .bottom)))`.

### Decision 3: Practice details in `.reflecting` state

**Chosen**: Add associated values to the `.reflecting` enum case: `practiceDescription: String` and `relevance: String`. The `logPractice` method captures these from the current `.suggesting` state's data.

**Alternatives considered**:
- *Mutable view model properties* (`currentPracticeDescription`, `currentRelevance`): Simpler but leaves dangling state after transitions; the enum naturally clears these on exit.
- *Look up from static library in ReflectionView*: Works for description but not for Gemini's per-transcript relevance text.

**Implementation**: Change `.reflecting(practiceName: String)` to `.reflecting(practiceName: String, practiceDescription: String, relevance: String)`. Update `logPractice` signature to accept `practice: Practice` and `relevance: String?`, derive all three values, and set the state. Update all switch case matches and equality tests.

### Decision 4: Back button in reflection phase 1

**Chosen**: A small "Back" text button (`font(.subheadline)`) in the top-left of `tryQuestion` that calls `onDismiss()` — the same path as the "No" button. The button disappears in phase 2 (the rating form).

**Rationale**: The existing "No" button semantically means "I didn't try the practice," which is a lie when the user simply tapped the wrong card. A separate "Back" button is honest and follows iOS conventions for reversible navigation.

### Decision 5: Inline navigation title

**Chosen**: `.navigationBarTitleDisplayMode(.inline)` on the `NavigationStack` in `RecordingScreen`.

**Rationale**: The large title "Check In" consumes ~52pt of vertical space and overlaps content on smaller devices. Inline mode gives content more room. The TabView's "Record" tab item already provides top-level context.

## Risks / Trade-offs

- **Accordion animation jank on older devices**: The expand/collapse uses `withAnimation(.easeInOut)` on a VStack height change. With only 2-3 cards this is lightweight. If performance is an issue, switch to `.animation(.default, value: expandedID)`.
- **`.reflecting` enum case change breaks pattern matches**: Every switch on `RecordingState` must add the two new associated values. This is mechanical — the compiler enforces exhaustiveness. Tests must be updated for equality checks.
- **Relevance string may be empty**: Gemini's `relevanceByID` dictionary may not have an entry for every practice. The code must handle `nil` relevance gracefully (show nothing or a placeholder).
- **ScrollView inside NavigationStack**: SwiftUI's `ScrollView` + `NavigationStack` interaction is well-tested in iOS 18+. No known issues at the deployment target.

## Open Questions

- None. All design decisions were resolved during the explore session.
