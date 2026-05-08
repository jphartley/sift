## Why

`GeminiService` currently owns prompt construction, response schema setup, model routing, network error translation, JSON parsing, retry classification, and debug logging in one class. Splitting those responsibilities now will make recommendation behavior easier to unit test without Gemini network calls and safer to evolve as memory, history limits, and model-routing rules grow.

## What Changes

- Extract prompt construction into a dedicated `GeminiPromptBuilder`.
- Extract structured response decoding and validation into a dedicated `GeminiRecommendationParser`.
- Extract or isolate Flash/Pro routing policy so confidence escalation and retryable fallback decisions can be tested without live network requests.
- Keep `GeminiService` as the production `RecommendationClient` facade used by the check-in flow.
- Preserve the existing Gemini models, prompt content, structured response contract, confidence threshold, and user-facing error behavior.
- Add focused unit tests for prompt building, parser validation, retry classification, and Flash/Pro routing decisions.

## Capabilities

### New Capabilities
- `gemini-service-composition`: Defines the internal composition and testability expectations for the Gemini recommendation client.

### Modified Capabilities
- `gemini-practice-recommendation`: Recommendation behavior must remain externally compatible while being implemented through smaller internal collaborators.
- `automated-tests`: Automated tests must cover Gemini prompt building, response parsing, and model-routing decisions without relying on live Gemini network requests.

## Impact

- Affected app code: `GeminiService`, any new collaborator files under `sift/Services/`, and possibly access levels for existing recommendation data types.
- Affected tests: `GeminiServiceTests` and any new service-level tests for builder/parser/router collaborators.
- No SwiftData schema changes are expected.
- No UI changes are expected.
- No new third-party dependencies are expected.
