## Context

The check-in flow now depends on `GeminiService` through the `RecommendationClient` protocol, which is the right external boundary for the app. Inside that boundary, however, `GeminiService` still does too much: it builds the prompt, defines the response schema, creates model instances, classifies retryable failures, routes between Flash and Pro, parses JSON, validates empty recommendations, and logs the outcome.

This is manageable for the current MVP, but it makes Gemini behavior hard to test precisely. Prompt construction tests currently instantiate the whole service. Retry classification is public only because tests need to reach into service internals. Parser behavior is only indirectly covered through hand-shaped expectations rather than isolated JSON cases. The next recommendation improvements, especially bounded history and richer memory, will be cleaner if these responsibilities are already split.

## Goals / Non-Goals

**Goals:**
- Keep `GeminiService` as the production `RecommendationClient` facade.
- Extract prompt construction into a small collaborator that can be tested directly.
- Extract response parsing and validation into a small collaborator that can be tested with deterministic JSON strings.
- Isolate Flash/Pro routing decisions from raw network calls enough to test confidence escalation and retryable fallback behavior without contacting Gemini.
- Preserve the current prompt content, model names, confidence threshold, response schema, and user-facing behavior.
- Keep the change scoped to service internals and tests.

**Non-Goals:**
- Do not change the check-in UI or `RecordingViewModel` behavior.
- Do not change `RecommendationClient` requirements unless implementation pressure proves the existing method shape insufficient.
- Do not add bounded history, summaries, conversational memory, or new recommendation ranking rules.
- Do not change `Session` or `PracticeAttempt` persistence models.
- Do not add a dependency injection framework or new third-party dependencies.
- Do not make live Gemini calls from unit tests.

## Decisions

### Keep `GeminiService` as the facade

`GeminiService` should remain the only production object that conforms to `RecommendationClient`. `RecordingViewModel` and `RecordingScreen` should continue to know only about recommendation behavior, not Gemini prompt builders, parsers, or routing details.

Alternative considered: expose builder/parser/router to the check-in flow. That would leak Gemini-specific implementation detail across the app and weaken the abstraction created by the service-boundary refactor.

### Extract prompt construction into `GeminiPromptBuilder`

Move `buildPrompt(transcript:history:)` and its date/history/practice-library formatting into a builder type. The builder can accept the practice library and date formatting strategy if needed, but it should preserve the current output contract unless tests identify accidental nondeterminism that needs a narrow fix.

Alternative considered: keep prompt construction as a public method on `GeminiService`. That keeps tests coupled to the facade and makes the upcoming history-bound work harder to isolate.

### Extract parsing into `GeminiRecommendationParser`

Move JSON decoding, required-field validation, practice list extraction, and empty-practice handling into a parser. Prefer typed `Decodable` structures over `[String: Any]` where practical so missing or malformed fields produce predictable errors.

Alternative considered: keep using `JSONSerialization` inline. That is simple, but it spreads schema knowledge through the network request path and makes malformed-response cases harder to cover.

### Isolate routing with injectable model request behavior

Keep model names and threshold near the production Gemini service, but introduce a small internal boundary that lets tests provide fake Flash/Pro responses and failures. This could be a `GeminiModelRequesting` protocol or a private closure-based requester owned by `GeminiService`. The chosen implementation should support testing:

- Flash high confidence returns Flash.
- Flash low confidence escalates to Pro.
- Flash retryable failure falls back to Pro.
- Non-retryable Flash failure does not call Pro.
- Pro failure after fallback surfaces the existing error behavior.

Alternative considered: fully abstract GoogleGenerativeAI `GenerativeModel`. That risks over-modeling the SDK. A narrow request boundary around "send prompt to model name and get text" is enough for this refactor.

### Keep schema construction near Gemini SDK integration

The GoogleGenerativeAI `GenerationConfig` and `Schema` setup can remain in `GeminiService` or move to a tiny factory if it meaningfully reduces clutter. The schema is tightly coupled to the SDK, so extracting it is useful only if it clarifies the service without creating a thin wrapper that tests do not need.

Alternative considered: move every helper out immediately. That would create more files than the current risk warrants.

## Risks / Trade-offs

- More types for a small service -> Keep each collaborator narrow and avoid a broad service layer.
- Tests could overfit exact prompt formatting -> Assert important sections and required content, not every newline, except for deliberately stable formatting.
- A routing abstraction could become too generic -> Model it around the current Flash/Pro flow only.
- Parser errors may become more specific than current UI messaging -> Map collaborator failures back to the existing `GeminiError` cases unless a behavior change is explicitly desired later.
- Access-level changes can leak internals -> Prefer `internal` for testable collaborators and keep SDK plumbing private where possible.

## Migration Plan

1. Add `GeminiPromptBuilder` and move prompt construction tests to target it directly.
2. Add `GeminiRecommendationParser` and cover valid JSON, malformed JSON, missing fields, malformed practice entries, and empty practice results.
3. Add a narrow model request boundary or routing helper and cover Flash/Pro decision paths without network calls.
4. Refactor `GeminiService` to compose the collaborators while preserving `RecommendationClient.recommend(transcript:history:)`.
5. Remove obsolete public/internal helper exposure from `GeminiService` where tests no longer need it.
6. Run the fast unit/integration test command, then full `xcodebuild test` before committing implementation.

Rollback is straightforward because this does not change persistence, app wiring, or user-facing flow. Revert the collaborator extraction and restore the previous `GeminiService` implementation if needed.

## Open Questions

- Should parser failures continue collapsing to `GeminiError.jsonParseError`, or should invalid shape versus invalid JSON become separately visible in tests while still mapping to the same UI message?
- Should retryable classification live in a standalone helper or inside the router/request boundary?
