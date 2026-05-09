## 1. Compact Practice Prompt

- [x] 1.1 Update `GeminiPromptBuilder` to format each practice with only id, name, category, duration, intensity, labels, summary, and best-fit situations.
- [x] 1.2 Ensure compact practice prompt entries omit steps, avoid-when guidance, keywords, and why-it-helps explanation.
- [x] 1.3 Keep the full decoded practice list eligible for prompt inclusion without adding local practice pre-filtering.

## 2. Bounded Smart History

- [x] 2.1 Add deterministic history selection in `SwiftDataSessionStore.recommendationHistory()` using recent sessions plus older helpful practice attempts.
- [x] 2.2 De-duplicate sessions that qualify through both recent and helpful selection.
- [x] 2.3 Preserve full transcripts, attempted practice names, and helpfulness ratings for selected history entries.
- [x] 2.4 Ensure recommendation history no longer returns unlimited prior sessions.

## 3. Tests

- [x] 3.1 Update `GeminiPromptBuilderTests` to assert compact practice fields are included and omitted rich execution fields are absent.
- [x] 3.2 Add session store tests covering bounded recent-plus-helpful history selection, de-duplication, and full transcript preservation.
- [x] 3.3 Update prompt size coverage to reflect compact catalog behavior with the expanded practice library.

## 4. Verification

- [x] 4.1 Run focused tests for prompt building and session store history behavior.
- [x] 4.2 Run full `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 4.3 Perform a scoped cleanup pass and check whether `AGENTS.md` needs updates.
