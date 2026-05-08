## 1. Prompt Builder

- [x] 1.1 Add `GeminiPromptBuilder` for constructing prompts from transcript, practice library, and session history.
- [x] 1.2 Move existing prompt construction behavior out of `GeminiService` while preserving current prompt content.
- [x] 1.3 Update prompt-related tests to target `GeminiPromptBuilder` without requiring Gemini network-capable service behavior.

## 2. Recommendation Parser

- [x] 2.1 Add `GeminiRecommendationParser` for decoding structured Gemini JSON into `RecommendationResult`.
- [x] 2.2 Validate required fields, malformed JSON, malformed practice entries, and empty practice lists through parser errors mapped to existing `GeminiError` behavior.
- [x] 2.3 Add parser tests for valid JSON, malformed JSON, missing required fields, partially malformed practice entries, and empty-practices responses.

## 3. Model Routing

- [x] 3.1 Introduce a narrow internal model request boundary or routing helper that can be faked in tests.
- [x] 3.2 Refactor Flash/Pro confidence escalation and retryable-failure fallback to use the routing boundary.
- [x] 3.3 Preserve `gemini-3-flash-preview`, `gemini-3.1-pro-preview`, and the 0.7 confidence threshold.
- [x] 3.4 Add routing tests for high-confidence Flash, low-confidence Flash escalation, retryable Flash failure fallback, non-retryable Flash failure, and Pro failure after fallback.

## 4. GeminiService Facade

- [x] 4.1 Refactor `GeminiService` to compose the prompt builder, parser, and routing/request collaborators while remaining the production `RecommendationClient`.
- [x] 4.2 Keep API-key validation, GoogleGenerativeAI SDK model creation, generation config, and response schema compatible with current behavior.
- [x] 4.3 Remove or reduce test-only public/internal helper exposure from `GeminiService` once collaborators own those tests.
- [x] 4.4 Ensure the check-in flow and app wiring do not depend directly on Gemini internals.

## 5. Cleanup and Verification

- [x] 5.1 Remove obsolete Gemini service tests that duplicate collaborator coverage.
- [x] 5.2 Run a scoped cleanup pass for unused imports, stale comments, and unnecessary abstraction introduced during the refactor.
- [x] 5.3 Check `AGENTS.md` for required architecture or testing updates after implementation.
- [x] 5.4 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -skip-testing:siftUITests`.
- [x] 5.5 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
