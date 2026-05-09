## 1. Presentation Copy

- [x] 1.1 Add or update view-adjacent suggestion presentation copy so the overall rationale label is "Why these might fit".
- [x] 1.2 Add or update view-adjacent suggestion presentation copy so expanded practice relevance uses the label "Why this might help".
- [x] 1.3 Remove the beta-facing "Escalated to Pro model" toast from the main suggestion UI while preserving internal escalation state.
- [x] 1.4 Ensure the main suggestion UI does not display provider names, model names, confidence scores, routing terms, or debug language.

## 2. Tests

- [x] 2.1 Add or update Swift Testing coverage for the suggestion rationale label and absence of the old "Analysis" label.
- [x] 2.2 Add or update Swift Testing coverage for expanded-card relevance labeling and continued relevance visibility.
- [x] 2.3 Add regression coverage proving escalated recommendation results do not expose model-routing copy in the main suggestion UI.
- [x] 2.4 Confirm existing Gemini routing and RecordingViewModel tests still cover internal escalation behavior.

## 3. Verification

- [x] 3.1 Run focused tests for suggestion view/presentation coverage.
- [x] 3.2 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 3.3 Perform the scoped cleanup pass for dead code, unused imports, stale comments, and project-pattern alignment.
- [x] 3.4 Check whether `AGENTS.md` needs updates for this change.
- [x] 3.5 Run `openspec validate improve-suggestion-explainability --strict`.
