## Context

`RecordingViewModel` currently coordinates microphone permission, recording, transcription, Gemini recommendation, history shaping, SwiftData persistence, and UI state transitions. This makes the production flow hard to unit test because tests cannot replace the recorder, transcriber, recommender, or persistence layer with deterministic fakes.

The app is still in the voice check-in MVP phase, so the goal is to improve internal seams before adding richer memory, conversational follow-up, practice management, or more complex recommendation logic. The refactor should preserve the existing SwiftUI environment pattern and the current SwiftData models.

## Goals / Non-Goals

**Goals:**
- Make the voice check-in flow testable through real `RecordingViewModel` method calls.
- Introduce narrow protocol boundaries for audio recording, transcription, recommendation, and session persistence/history.
- Keep production behavior and user-facing states equivalent unless an existing silent failure is intentionally surfaced as an error.
- Replace misleading tests that manually reproduce persistence behavior with tests using protocol-backed fakes.
- Keep changes scoped to the existing MVP architecture and SwiftData schema.

**Non-Goals:**
- Do not add new recommendation features, model routing rules, or memory logic.
- Do not change the `Session` or `PracticeAttempt` schema.
- Do not replace SwiftData.
- Do not redesign the UI.
- Do not add third-party dependency injection frameworks.

## Decisions

### Define protocols around current use, not implementation detail

Create small protocols such as `AudioRecording`, `TranscriptionClient`, `RecommendationClient`, and `SessionStore` that expose only what `RecordingViewModel` needs. Production services conform to these protocols, while tests use lightweight fakes.

Alternative considered: keep concrete services and add test-only hooks. That would preserve coupling and continue encouraging tests to bypass the actual flow.

### Move SwiftData access behind a session store

Introduce a production `SwiftDataSessionStore` that wraps `ModelContext` operations for saving sessions and reading recommendation history. `RecordingViewModel` should request history and persistence through the store instead of directly creating `FetchDescriptor`s or calling `context.save()`.

Alternative considered: only protocolize recorder/transcription/Gemini and leave `ModelContext` in the view model. That would still leave persistence failure handling and history shaping difficult to test.

### Keep app-level service ownership

Continue creating long-lived `TranscriptionService` and `GeminiService` instances at app launch. `RecordingScreen` can assemble the view model dependencies from the SwiftUI environment and a `SwiftDataSessionStore` built from `modelContext`.

Alternative considered: introduce a full dependency container. That is unnecessary for the current app size and would add abstraction before it is needed.

### Make persistence failures observable

Persistence methods should throw instead of swallowing save errors. `RecordingViewModel` should surface save failures through its existing `.error(String)` state or a similarly testable state transition.

Alternative considered: keep `try?` saves to minimize UI changes. That preserves a real data-loss risk and makes failure tests impossible.

### Preserve recommendation routing inside GeminiService

`GeminiService` should conform to `RecommendationClient`, but Flash/Pro routing and structured response parsing should remain encapsulated inside it for this change. Further splitting into prompt builder/parser/router can happen later if needed.

Alternative considered: split all Gemini internals immediately. That is valuable, but it would enlarge this change beyond the first testability refactor.

## Risks / Trade-offs

- Protocols can become noisy if they mirror whole concrete classes -> Keep each protocol limited to what the check-in flow calls.
- `RecordingScreen` setup may become more verbose -> Prefer a small initializer/configure path over a broad dependency container.
- Fakes can drift from production behavior -> Keep fakes minimal and assert calls/results that matter to the view model.
- Surfacing save failures may expose error paths that were previously hidden -> Treat this as desired correctness behavior and cover it with tests.
- `SessionStore` could become a dumping ground -> Keep it focused on session save and recommendation history for this change.

## Migration Plan

1. Add protocol definitions and production conformances without changing call sites.
2. Add `SessionStore` and production SwiftData implementation.
3. Refactor `RecordingViewModel` initializer/configuration to accept protocol dependencies.
4. Update `RecordingScreen` to provide production dependencies.
5. Replace or rewrite view model tests to use fakes and call real methods.
6. Run fast unit/integration tests, then full `xcodebuild test` before commit.

Rollback is straightforward because the SwiftData schema and user-facing flow are unchanged; revert the protocol refactor and restore direct concrete dependencies if needed.

## Open Questions

- Should failed persistence keep the pending session available for retry, or return the user to suggestions/reflection with an error banner?
- Should `SessionStore` also own `previouslyHelpfulIDs`, or should that remain a view concern until the next UI/data cleanup?
