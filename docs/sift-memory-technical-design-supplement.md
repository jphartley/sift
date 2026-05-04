# Sift Memory Technical Design Supplement

This document supplements the product requirements document for Sift by defining a first-pass technical design for the memory system, with a specific focus on conversational continuity, privacy-forward storage, and explainable longitudinal recall [file:1]. It translates the PRD's memory goals into a practical architecture that can guide implementation decisions for MVP and early iterations [file:1].

## Purpose

Sift's PRD positions memory as a core part of the product experience rather than a background feature: the app should remember prior wins, continue the relationship across long gaps, and support voice-first check-ins with awareness of context, practices, and recent days [file:1]. The memory system therefore needs to do more than store logs; it needs to help the assistant respond as an ongoing companion while remaining calm, privacy-forward, and non-preachy [file:1].

This supplement focuses on the memory layer only. It does not redefine the full PRD, practice library, or onboarding architecture, but instead provides a concrete structure for how memory should be represented, retrieved, updated, and surfaced in conversation [file:1].

## Design goals

The memory system should optimize for conversational continuity over time, especially across weeks and months, rather than acting only as a short-term session memory [file:1]. It should regularly use memory in the product experience, but do so with balanced phrasing, occasional direct callbacks, and careful handling of uncertainty so the app feels grounded rather than overconfident [file:1].

The design should also support several explicit PRD constraints: all personal data should live on-device or in the user's private iCloud, the system must degrade gracefully when history is sparse, and HealthKit signals should be incorporated carefully without overstating causal relationships between biometrics and subjective well-being [file:1]. AI response latency is expected to remain fast enough for an in-app conversational flow, with the PRD targeting about two seconds on average [file:1].

## Memory principles

The following principles should shape implementation:

- Memory is conversation-first. Retrieval exists to make replies feel continuous, not just to select interventions [file:1].
- Long-term patterns matter. The system should privilege durable context across months, especially prior wins, recurring life contexts, and resistance patterns [file:1].
- Stable memory is allowed. Sift should form long-term memory objects rather than relying only on raw logs and ad hoc summarization [file:1].
- Memory should be explainable. Whenever possible, surfaced memories should be traceable back to underlying evidence such as past reflections, practice attempts, or session summaries [file:1].
- Health data should inform memory quietly. HealthKit signals can contribute to context and may be spoken conversationally, but they should not dominate the relationship or produce confident causal claims unsupported by evidence [file:1].
- Users should be able to correct memory conversationally. The system should accept feedback such as “that’s not really true anymore” or “that only applies when I’m traveling,” without requiring manual record editing [file:1].
- Uncertain memory should be phrased carefully. When a recalled pattern is plausible but not strongly supported, Sift should hedge rather than present it as fact [file:1].

## Architectural overview

The recommended architecture is hybrid: SQL stores durable structured truth, while a vector index stores semantically searchable conversational artifacts [file:1]. This split is important because Sift needs both deterministic rule-based behavior, such as practice status and trial counts, and fuzzy meaning-based recall from free-form voice transcripts, reflections, and summaries [file:1].

At a high level, the memory stack should include four layers:

1. **Raw evidence layer**: sessions, messages, practice attempts, reflections, and HealthKit daily rollups [file:1].
2. **Episodic memory layer**: compact summaries of sessions or meaningful periods, suitable for semantic retrieval [file:1].
3. **Stable memory layer**: canonical facts inferred from repeated evidence, such as recurring helpful practices, avoidance patterns, or repeated life contexts [file:1].
4. **Response packet layer**: a small, curated memory bundle assembled for each conversational turn and passed to the model for response generation [file:1].

This architecture preserves auditability and privacy while keeping generation grounded in a small, interpretable context window [file:1].

## Data model

### Core SQL tables

The structured store should be local-first and optimized for deterministic retrieval, evidence tracking, and lifecycle updates [file:1]. The following tables provide a first-pass schema.

| Table | Purpose | Representative fields |
|---|---|---|
| `sessions` | Captures each check-in or interaction session | `id`, `started_at`, `ended_at`, `mode`, `return_after_gap_days`, `summary_text`, `summary_confidence` |
| `messages` | Stores user and assistant turns for a session | `id`, `session_id`, `role`, `text`, `timestamp`, `emotion_labels`, `context_labels` |
| `practice_attempts` | Stores structured practice activity and feedback | `id`, `session_id`, `practice_id`, `timestamp`, `completed`, `helpfulness_score`, `resistance_score`, `reflection_text` |
| `health_daily` | Stores daily HealthKit rollups | `date`, `sleep_minutes`, `hrv`, `resting_hr`, `steps`, `data_quality` |
| `memory_facts` | Stores stable long-term memory objects | `id`, `type`, `subject`, `predicate`, `object`, `confidence`, `status`, `first_seen_at`, `last_seen_at`, `evidence_count`, `speakability` |
| `memory_evidence` | Links memory facts to source evidence | `id`, `memory_fact_id`, `source_type`, `source_id`, `weight` |
| `weekly_summaries` | Stores generated weekly narrative continuity objects | `id`, `week_start`, `week_end`, `summary_text`, `themes`, `top_practices`, `generated_at` |
| `memory_feedback` | Stores user corrections or challenges to memory | `id`, `memory_fact_id`, `feedback_type`, `feedback_text`, `created_at` |

The `sessions`, `messages`, and `practice_attempts` tables serve as the core evidence model for the conversational and behavior history described in the PRD [file:1]. The `health_daily` table supports HealthKit integration while keeping the conversational system grounded in normalized daily snapshots instead of raw event streams [file:1].

### Stable fact representation

The central long-term memory table should be `memory_facts`. A stable fact is not just prose; it is a structured memory object supported by evidence and intended to be retrievable, updatable, and possibly surfaced in conversation [file:1].

A triple-like shape is recommended:

- `subject`
- `predicate`
- `object`

Examples:

- `practice:breathwork` - `helps_in_context` - `work_stress`
- `practice:journaling` - `high_resistance_at` - `evening`
- `context:travel` - `associated_with` - `routine_disruption`
- `health:sleep_low` - `co_occurs_with` - `lower_energy`

This format makes it easier to reason over patterns, apply confidence logic, trace evidence, and support later user corrections than a system built only on free text [file:1]. It also supports the PRD's desired explainability, such as “this helped when you felt this way last time,” because the surfaced statement can be grounded in both a fact and its source evidence [file:1].

### Fact fields

Each stable memory fact should include at least the following:

- `type`: such as `practice_win`, `practice_resistance`, `context_pattern`, `health_correlation`, `time_of_day_tendency`
- `confidence`: continuous score from 0 to 1
- `status`: `active`, `disputed`, `superseded`, `archived`
- `evidence_count`: number of supporting evidence items
- `speakability`: `internal_only`, `cautious`, `normal`
- `first_seen_at` and `last_seen_at`: for tracking drift over time

The `speakability` field is especially important for Sift. It allows the system to retain useful but sensitive or weakly supported memory facts, especially health-related ones, without automatically surfacing them in conversation [file:1].

## Vector memory design

The vector store should not mirror the SQL database blindly. It should index only those artifacts where semantic similarity is useful for conversation continuity [file:1].

Recommended vector document types:

| Document type | Purpose | Example content |
|---|---|---|
| `message_chunk` | Recall similar user language and emotional framing | A single user utterance or small chunk of adjacent turns |
| `session_summary` | Retrieve compact episodic context | “User felt overloaded before a deadline; short walk reduced tension slightly.” |
| `reflection_note` | Recall practice-specific qualitative evidence | “Breathwork helped settle racing thoughts before bed.” |
| `weekly_summary` | Retrieve narrative continuity across longer periods | Weekly prose summary of what seemed to help or hurt |
| `memory_anchor` | Surface natural-language versions of stable facts | “Short walks have often helped during work-heavy weeks.” |

Each vector document should include metadata filters such as `created_at`, `session_id`, `practice_ids`, `context_labels`, `emotion_labels`, `health_tags`, and `confidence_band`. That allows the system to use semantic search within constrained, relevant candidate sets rather than relying on raw similarity alone [file:1].

## Memory retrieval strategy

For Sift, retrieval should be designed around conversational continuity rather than broad recommendation ranking. The system's job is to retrieve the few memories that make the next reply feel like a continuation of an ongoing relationship [file:1].

### Retrieval flow for a conversational turn

A practical turn-level retrieval flow is:

1. Persist the new user message in `messages` and attach lightweight emotion and context labels [file:1].
2. Query SQL for high-confidence stable facts relevant to the current context, especially prior wins, recurring contexts, resistance patterns, and recent return-gap signals [file:1].
3. Query the vector store for semantically similar prior episodes, reflections, and summaries, with recency and confidence re-ranking [file:1].
4. Pull a lightweight health context summary only when relevant and sufficiently supported [file:1].
5. Assemble a bounded response packet for generation [file:1].
6. Generate the reply, referencing only a small number of memories so the response remains natural and calm [file:1].
7. After the session, run compaction and update routines that may create new summaries or adjust stable facts [file:1].

This hybrid approach uses SQL as the constraint and evidence layer while using vector search as the continuity layer [file:1].

### Ranking logic

A blended ranking model should combine:

- Semantic similarity to current language and context [file:1]
- Stability of the memory fact or episode [file:1]
- Recency, without letting very recent low-signal events dominate [file:1]
- Evidence strength and confidence [file:1]
- Speakability and sensitivity controls [file:1]
- Penalties for disputed or outdated memory [file:1]

The highest-ranked items should not automatically all be surfaced. A separate selection rule should limit the final set to a small memory packet that improves the next conversational turn without overwhelming the user [file:1].

## ConversationMemoryPacket

A dedicated intermediate object should sit between retrieval and response generation. This avoids sending raw database results directly into the model and creates a clean contract between memory infrastructure and conversation logic [file:1].

### Proposed shape

```json
{
  "current_turn": {
    "user_text": "",
    "session_id": "",
    "mode": "check_in",
    "detected_emotions": [],
    "detected_contexts": []
  },
  "session_memory": {
    "open_loops": [],
    "recent_thread_summary": ""
  },
  "recent_relevant_episodes": [
    {
      "source_id": "",
      "kind": "session_summary",
      "text": "",
      "relevance_score": 0.0,
      "recency_days": 0
    }
  ],
  "long_term_memory": [
    {
      "memory_fact_id": "",
      "text": "",
      "type": "practice_win",
      "confidence": 0.0,
      "speakability": "normal"
    }
  ],
  "health_context": {
    "enabled": true,
    "summary": "",
    "confidence": 0.0,
    "speakability": "cautious"
  },
  "response_guardrails": {
    "mention_uncertainty": true,
    "avoid_causal_claims": true,
    "avoid_excluded_practices": true,
    "tone": "warm_supportive_non_preachy"
  }
}
```

This object reflects the product direction established in the PRD and the design decisions clarified in this supplement: strong continuity, stable long-term memory, cautious health signaling, and a tone that remains warm and grounded [file:1].

### Packet rules

The `ConversationMemoryPacket` should remain deliberately small. It should usually contain:

- the current turn and thread state [file:1]
- one short session-level summary [file:1]
- two to four highly relevant episodic recalls [file:1]
- one to three stable long-term memories [file:1]
- at most one health context note, usually cautious [file:1]
- explicit response guardrails [file:1]

The system should not try to maximize memory recall volume. The goal is selective continuity, not exhaustive recollection [file:1].

## Memory lifecycle

A clear lifecycle is important for quality and trust. Not every observed event should become a long-term memory fact [file:1].

### Stages

1. **Evidence capture**: raw messages, practice attempts, reflections, and health snapshots are stored as evidence [file:1].
2. **Episodic summarization**: each session or meaningful cluster is summarized into a short retrievable note [file:1].
3. **Fact promotion**: repeated evidence can promote an emerging pattern into a stable `memory_fact` [file:1].
4. **Speakability gating**: stable facts are separately assessed for whether they are safe and useful to surface in conversation [file:1].
5. **User correction and drift handling**: facts can be disputed, weakened, or superseded based on newer evidence or direct user feedback [file:1].

### Promotion policy

The default policy should be conservative:

- One-off events stay as evidence only [file:1].
- Repeated similar episodes can become episodic summaries [file:1].
- Stable facts require multiple supporting signals across time [file:1].
- Abstract pattern statements should face a higher threshold than concrete statements about a specific helpful practice or recurring context [file:1].
- Health-related patterns should have a higher threshold for conversational surfacing than non-health patterns [file:1].

This matches the product requirement to feel supportive and intelligent without becoming overly assertive about a person's mental or physical state [file:1].

## User correction model

Users should be able to correct memory, but correction should happen through conversation or direct feedback, not manual record editing. This matches the intended low-friction, voice-first nature of the product [file:1].

Examples of conversational corrections include:

- “That used to help, but not lately.”
- “That’s only true when work is busy.”
- “I don’t think that pattern is right.”

These signals should create rows in `memory_feedback` and trigger one of the following effects:

- lower confidence in the fact [file:1]
- narrow the fact to a more specific context [file:1]
- mark the fact as disputed [file:1]
- create a superseding fact [file:1]

Evidence should generally not be deleted when a fact is challenged. The system should preserve historical traceability while allowing current understanding to change [file:1].

## Health memory policy

HealthKit data is a meaningful source of context in the PRD, but it should be integrated with restraint [file:1]. The system should avoid turning biometrics into strong explanations for the user's emotional state, especially when those inferences are weak or merely correlational [file:1].

Recommended policy:

- Health rollups may contribute to retrieval and ranking [file:1].
- Health notes may appear in the conversation when relevant, but usually in soft language and with caution [file:1].
- The system should avoid statements that imply causality, such as claiming a mood state was caused by a biometric signal, unless the user explicitly frames it that way and evidence is very strong [file:1].
- Health-related stable facts should default to `cautious` or `internal_only` speakability until repeatedly supported [file:1].

A safe conversational pattern is to frame health signals as part of context rather than as a diagnosis or explanation [file:1].

## Sparse history behavior

The PRD explicitly notes that the memory architecture must degrade gracefully when history is sparse [file:1]. This means the system should avoid pretending to know more than it does.

Early-user behavior should include:

- relying more on the current conversation and explicit user input [file:1]
- surfacing tentative language for weakly supported patterns [file:1]
- favoring specific, recent evidence over broad pattern statements [file:1]
- keeping the memory packet small and simple [file:1]

As history accumulates, the system can gradually shift toward stronger long-term continuity and more confident pattern recall [file:1].

## Privacy and storage

The architecture should remain local-first. The PRD states that personal data should be stored on-device or in the user's private iCloud, with no central health data server or external analytics [file:1]. Voice processing should happen on-device where possible, and memory storage should follow the same privacy posture [file:1].

Implementation implications:

- SQL store local on device, synced via private iCloud if enabled [file:1]
- vector index local on device, or encrypted and private if synced [file:1]
- all memory objects traceable to local evidence [file:1]
- deletion and retention operations applied consistently to both SQL and vector layers [file:1]

This approach keeps the technical design aligned with the product's trust model [file:1].

## V1 scope recommendation

For MVP and early launch, the memory system should intentionally narrow scope while preserving the right architecture [file:1].

Recommended V1 in-scope memory types:

- prior helpful practices [file:1]
- recurring practice resistance [file:1]
- recurring life contexts such as work stress or travel [file:1]
- simple time-of-day tendencies where evidence is clear [file:1]
- basic health context notes with cautious surfacing [file:1]
- session summaries and weekly summaries [file:1]

Recommended V1 out-of-scope or high-threshold memory types:

- strong causal claims linking biometrics to subjective state [file:1]
- highly abstract personality-like patterning [file:1]
- overly broad identity statements such as “you are the kind of person who...” [file:1]

This keeps the first release aligned with the PRD's supportive, grounded product voice [file:1].

## Open implementation questions

Several questions remain intentionally open for implementation design rather than product direction:

- How confidence scores should be computed across mixed evidence types [file:1]
- How often session summaries and weekly summaries should be regenerated [file:1]
- Whether embeddings should be computed fully on-device in V1 or support a privacy-focused fallback path [file:1]
- How the testing-oriented memory summary screen should expose stable facts and disputed memory without overwhelming the user [file:1]

These are engineering and iteration questions rather than blockers to the architecture outlined here [file:1].

## Summary

The recommended memory system for Sift is a hybrid, local-first architecture designed to make conversation feel continuous across time while staying explainable and privacy-forward [file:1]. SQL stores durable evidence and stable facts; vector search supports semantic episodic recall; a curated `ConversationMemoryPacket` mediates what the model sees; and user corrections refine memory through conversation rather than manual editing [file:1].

This design gives Sift a credible way to remember prior wins, recurring contexts, and meaningful patterns without becoming brittle, invasive, or overconfident, which is consistent with the role the PRD gives memory in the overall product experience [file:1].
