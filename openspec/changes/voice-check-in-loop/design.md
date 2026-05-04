## Context

The current prototype is a single-shot record → transcribe → rate loop backed by a `TestResult` SwiftData model. The app has two tabs: Record (the test loop) and History (past test results). WhisperKit transcription with `openai_whisper-base.en` loads on launch and works reliably.

This change converts the test harness into the first real product feature: a voice check-in that suggests wellness practices and captures whether they helped. No LLM or cloud AI is involved — the MVP relies on a hardcoded practice library and simple keyword matching.

## Goals / Non-Goals

**Goals:**
- Replace the "rate the transcription" flow with a "try this practice" flow
- Introduce a curated, hardcoded practice library
- After transcription, display 2–3 practice suggestions based on keyword matching against the user's spoken text
- Allow the user to log whether they tried a practice and whether it helped
- Persist sessions and practice attempts via SwiftData
- Show session history with past practices and helpfulness
- Surface previously helpful practices first (basic recency-based memory)

**Non-Goals:**
- LLM-based practice recommendation or conversation
- HealthKit integration
- Full conversational memory (memory_facts, vector store, etc.)
- Practice resistance scoring or trial thresholds
- Weekly summaries
- Onboarding flow
- Practice management (add/remove from library)
- Voice output (text only)

## Decisions

### 1. Data model: Session and PracticeAttempt replace TestResult

`TestResult` supports transcription validation — it captures accuracy, intent capture, and latency. None of those are relevant to the product. Two new models replace it:

- **Session**: Represents one check-in. Fields: `id`, `timestamp`, `transcript`, `audioDuration`, `transcriptionDurationMs`. A session can have many practice attempts.
- **PracticeAttempt**: Represents the user engaging with a suggested practice. Fields: `id`, `session`, `practiceID`, `timestamp`, `completed` (Bool), `wasHelpful` (Bool? — nil until rated), `notes`. One-to-many from Session.

**Alternatives considered**: Extending `TestResult` with optional practice fields. Rejected — the TestResult fields (accuracy, reference text, intent capture) are noise in the product flow and the model name itself conveys the wrong purpose.

### 2. Practice library: hardcoded Swift struct array

Practices are defined as a static array of `Practice` structs with: `id`, `name`, `category`, `keywords` (for matching), `description`, `durationEstimate`. No dynamic CRUD — users cannot add/remove practices in this MVP. The library is curated to 10–15 practices across categories like breathwork, movement, journaling, social, nature, sensory.

**Alternatives considered**: JSON file bundled with the app. Rejected — a Swift array is simpler, type-safe, and has no parsing overhead. The library is small enough that hardcoding is fine.

### 3. Practice suggestion: keyword matching, not LLM

After transcription, the transcript text is lowercased and matched against each practice's `keywords` array. Practices with the most keyword hits are surfaced first, with a minimum of 3 always shown (falling back to the most commonly helpful practices when no keywords match). This is intentionally simple — the goal is to test whether the transcription → suggestion flow feels right, not to optimize recommendation quality.

**Alternatives considered**: LLM-based recommendation. Rejected — explicitly out of scope for this phase per AGENTS.md. Can be added later as a drop-in replacement for the matching function.

### 4. Memory: recency-weighted + previously helpful first

Practice suggestions are sorted with a simple scoring function:
- `baseScore = keywordMatchCount`
- `bonus = 1.0` if the practice was marked helpful in any prior session
- Ties broken by most recent helpful attempt first

No persistent memory_facts table yet — this is a stateless query over past PracticeAttempts.

**Alternatives considered**: Separate memory store. Rejected — premature for MVP when a SwiftData query over past attempts suffices.

### 5. UI flow: single-screen with state-driven views

The `RecordingScreen` remains the central screen, driven by `RecordingViewModel`'s state enum. The state enum gains a new case for practice suggestions, and the result view is replaced:

- `idle` → `loadingModel` → `ready` (unchanged)
- `recording` → `transcribing` (unchanged)
- **NEW**: `suggesting(transcript: String)` — shows transcript + 2–3 practice cards. User taps one to try it.
- **NEW**: `reflecting(Session, PracticeAttempt)` — shows "Did you try [practice]?" with yes/no and "Did it help?" thumbs up/down, plus optional notes.
- **REMOVED**: `result(transcript: String, latencyMs: Int)` — accuracy/intent-capture rating is gone.

The History screen evolves from listing `TestResult` entries to listing `Session` entries, with each session expandable to show its practice attempts.

### 6. SwiftData migration: lightweight

Since this is a pre-release prototype with no users, no migration is needed — the old `TestResult` model is simply deleted. The `ModelContainer` in `siftApp.swift` switches from `TestResult.self` to `Session.self, PracticeAttempt.self`. Existing test data is lost, which is acceptable at this stage.

## Risks / Trade-offs

- **Keyword matching is crude** → Users may get irrelevant suggestions when keywords don't match their intent. Mitigation: always show the top 3 globally helpful practices as fallback. This is acceptable for an MVP testing the flow, not the recommendation quality.
- **No structured memory** → Previously helpful practices are just sorted higher, not contextualized (e.g., "this helped last time you felt stressed"). Mitigation: this is V1 scope per the memory supplement. A basic "Previously helped you" badge on the practice card is enough for now.
- **Hardcoded practice library** → No personalization possible. Mitigation: the library is curated to be broadly applicable. User-customized practices come in a later phase.
- **Lost transcription-accuracy data** → The TestResult history is the only evidence of WhisperKit performance from the prototyping phase. Mitigation: export or screenshot before merging. The prototype data has served its purpose.

## Open Questions

- How many practices should be in the initial library? (Recommendation: 10, covering breathwork, movement, journaling, social, nature, sensory categories)
- Should practice cards show estimated duration? (Recommendation: yes, shows `~5 min` etc. to reduce friction)
- Should the user be able to skip reflection entirely (mark done without rating)? (Recommendation: yes — completion alone is a signal; helpfulness is optional)
