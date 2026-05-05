## Context

Sift's current recommendation system uses pure keyword matching: tokenize the transcript, intersect with practice keywords, rank by match count + previously-helpful bonus. This cannot understand semantic meaning (e.g., "I feel like I'm drowning" won't match "overwhelm") and offers no explanation — just a ranked list. Gemini adds comprehension and trust-building rationale.

The app runs WhisperKit on-device for transcription. Gemini is the first network dependency.

## Goals / Non-Goals

**Goals:**
- Analyze transcript + user history with Gemini to select 2–3 practices from the fixed library
- Return an overarching rationale and per-practice relevance text
- Default to `gemini-3-flash-preview`, escalate to `gemini-3.1-pro-preview` on low confidence (< 0.7)
- Persist rationale, model used, and confidence with the Session
- Show inline error with retry when Gemini fails
- Keep Gemini API key out of source control

**Non-Goals:**
- Offline fallback to keyword matching (MVP assumes always online)
- Dynamic practice library (library remains hardcoded)
- User-provided API keys
- Streaming responses (batch request/response only)
- Optimizing prompt size or history pruning
- LLM summarization of transcripts

## Decisions

### 1. SDK: google-generative-ai-swift

The official Google SDK provides structured output (JSON mode), retry handling, and a clean Swift async API. Raw `URLSession` would require building response parsing, structured output enforcement, and error handling from scratch. The cost of a second SPM dependency is low compared to the scaffolding avoided.

**Alternative**: Raw `URLSession` calls — lighter but would require building JSON schema enforcement and response parsing manually. Rejected for MVP speed.

### 2. API key via gitignored Swift source file

`Secrets.swift` contains a hardcoded constant `Secrets.geminiApiKey`, read directly by `GeminiService` at call time. The file is gitignored; a `Secrets.swift.example` template is committed with a placeholder. This avoids the `INFOPLIST_KEY_` mechanism which does not support custom keys.

**Alternative**: xcconfig + `INFOPLIST_KEY_` injection — rejected because Xcode only processes `INFOPLIST_KEY_` for recognized Apple keys, silently dropping custom keys like `GEMINI_API_KEY`.

### 3. GeminiService as @Observable singleton injected via environment

Follows the existing `TranscriptionService` pattern: created once in `siftApp.init()`, stored as `@State`, injected via `.environment()`, consumed via `@Environment`. This keeps `RecordingViewModel` testable (can inject mock) and the DI surface consistent.

```
siftApp
  ├── TranscriptionService (@State, .environment)
  └── GeminiService (@State, .environment)
         consumed by RecordingViewModel via configure()
```

### 4. Prompt structure

The prompt includes:
- System instruction: role, task, output format
- Full practice library (name, description, category, duration) — not keywords
- User's current transcript
- Rich history: all prior sessions with transcript (full), practice attempted, helpfulness rating
- Output schema: JSON with `rationale`, `practices[]`, `confidence`

History is not truncated for MVP. Prompt size is accepted as a known risk (see Trade-offs).

### 5. Routing: Flash → Pro on low confidence or transient server errors

```
Request → gemini-3-flash-preview
  ├── success + confidence ≥ 0.7 → use result
  ├── success + confidence < 0.7 → escalate to gemini-3.1-pro-preview
  └── failure (503, 429, 5xx, unavailable) → auto-fallback to gemini-3.1-pro-preview
                                                (transparent, no user-facing error)
```

If both Flash and Pro fail → show error with retry button. Retry always starts with Flash. Only one escalation attempt is made per request (no infinite chain).

Transient server errors are detected by matching known patterns in the error description (status codes 429, 500, 502, 503, 504; messages containing "unavailable", "high demand", "rate limit", etc.), since the underlying `RPCError` type is internal to the SDK.

### 6. Structured output via JSON schema

Gemini's native structured output / response schema is used. The expected shape:

```json
{
  "rationale": "string explaining why these practices were chosen",
  "practices": [
    {"practice_id": "box-breathing", "relevance": "why this practice fits this user right now"},
    {"practice_id": "morning-pages", "relevance": "..."}
  ],
  "confidence": 0.85
}
```

### 7. New RecordingState.analyzing

The state machine gains a step between `.transcribing` and `.suggesting`:

```
idle → loadingModel → ready → recording → transcribing → analyzing → suggesting
                                                                       ↓
                                                                   reflecting → ready
```

`analyzing` shows a spinner with "Analyzing..." text. Pro escalation does not need a separate visible state — it happens transparently within the analyzing phase, with a brief developer notification overlay shown briefly afterward.

### 8. Session data model additions

Three optional fields added to `Session`:

| Field               | Type      | Purpose                                |
|---------------------|-----------|----------------------------------------|
| `geminiRationale`   | `String?` | Overarching recommendation rationale   |
| `geminiModelUsed`   | `String?` | Which model produced the result        |
| `geminiConfidence`  | `Double?` | Self-reported confidence (0.0–1.0)     |

These live directly on `Session` (not a separate model) because they are 1:1 with a session's suggestion phase. If a session has no recommendations (skipped), all three remain nil.

### 9. SuggestionView changes

The view gains:
- An overarching rationale banner at the top (`geminiRationale` from the response)
- Per-practice relevance text below each practice card
- A developer-only toast/notification when Pro escalation occurred (shows "Escalated to Pro model" briefly, removed before production)

The existing `previouslyHelpfulIDs` badge ("Helped before") is preserved independently — it comes from SwiftData, not from Gemini.

## Risks / Trade-offs

- **Large prompt size** → All history + full transcripts + practice library in every request. Token costs and latency increase over time. Mitigation: accepted for MVP; history pruning will be added post-MVP.
- **Network dependency** → App now requires connectivity for the core recommendation flow. Mitigation: explicit error + retry UI; offline fallback deferred to post-MVP.
- **API key in binary** → xcconfig injection puts the key in the compiled IPA. Mitigation: acceptable for internal/TestFlight distribution; production distribution would need server-side proxy.
- **Gemini model availability** → Preview models may be deprecated or changed. Mitigation: model names are centralized in `GeminiService` as constants, easy to update.
- **Non-deterministic output** → Same transcript may get different recommendations/confidence across calls. Mitigation: confidence threshold provides a signal; persisted rationale allows debugging.

## Open Questions

None — all design decisions resolved during exploration.
