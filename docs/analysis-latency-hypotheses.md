# Analysis-phase latency — hypotheses & experiment plan

Date: 2026-05-15
Status: **Awaiting first data.** Instrumentation is live (see [openspec/changes/instrument-pipeline-metrics](../openspec/changes/instrument-pipeline-metrics/)); no measurements collected yet. Once a few days of organic usage produce data on the in-app debug tab, revisit this doc and prune the suspect list.

Companion to: the OpenSpec change that added `MetricRecorder`, `MetricEvent`, the `#if DEBUG` debug tab, and the Swift Testing benchmark harness.

---

## The problem

The user-perceived "analysis phase" — from `.analyzing` to `.suggesting` in [RecordingViewModel](../sift/ViewModels/RecordingViewModel.swift:147) — feels like ~30 seconds in normal use. That's well above any reasonable budget for a single Gemini call against `gemini-3-flash-preview`. We don't yet know where the time actually goes; this doc captures the leading suspects, the experiments that would distinguish them, and the decision rules for what to try first based on what the data reveals.

The investigation is scoped to **just the Gemini portion** of the pipeline. Whisper and other slow operations are being instrumented opportunistically (see Tier B in the proposal) but are not the primary target.

---

## Pipeline shape

```
[stop tap]
   │
   ▼
.transcribing ──► whisper.download    (one-shot, first launch only)
                  whisper.modelLoad   (every cold launch)
                  whisper.transcribe  (every session)
   │
   ▼
.analyzing   ──► swiftdata.historyFetch  (load prior sessions for prompt)
                 practiceLibrary.load    (first access only, then cached)
                 gemini.flash            (always)
                       │
                       ▼
                 confidence >= 0.7 ?
                  ┌────┴────┐
                 yes        no
                  │          │
                  │          ▼
                  │     gemini.pro    (escalation)
                  │          │
                  ▼          ▼
                 .suggesting  (atomic, no streaming)
                       │
                       ▼
                 swiftdata.sessionSave
```

Threshold is `0.7` ([GeminiRecommendationRouter.swift:19](../sift/Services/GeminiRecommendationRouter.swift:19)). Escalation is **strictly serial** — Pro only fires after Flash has returned a low-confidence result.

---

## What to look for in the data once it lands

These are the diagnostic patterns that distinguish hypotheses. Read this section first when reviewing the metric history.

### 1. Pro-escalation rate — the elephant
- Look at: `Escalations` pill on the debug screen, or count of `gemini.pro` events vs `gemini.flash` events.
- **>30% escalations** → escalation cost is likely the dominant slow-tail driver. Investigate threshold first (cheapest fix).
- **<10% escalations** → escalation isn't the primary cause; look elsewhere.
- **Bimodal latency distribution** (most sessions fast, some sessions ~2× slower) → strong escalation signal even if the rate seems modest, because escalations roughly double the wall-clock.

### 2. Flash confidence distribution
- Look at: `gemini.flash` event metadata (confidence values across many sessions).
- **Cluster at 0.6–0.69** → the threshold is acting as an "always escalate" trigger in disguise. The model's natural confidence floor for genuine recommendations might just sit below 0.7.
- **Wide spread, only outliers below 0.7** → threshold is well-positioned, escalations are genuinely "the model is uncertain" cases.

### 3. Flash latency in isolation
- Look at: `gemini.flash` p50 and p95.
- **p50 > 5s** → preview-endpoint or schema-overhead suspects rise. This is *one call*, no escalation, and shouldn't be slow.
- **p50 < 3s, p95 > 10s** → variance is the issue, not baseline latency. Likely server-side (Gemini load, geographic routing) — harder to optimize from our side.

### 4. Total minus Flash minus Pro = "everything else"
- Look at: `gemini.total - gemini.flash - (gemini.pro ?? 0)`.
- **<200ms** → parser, schema validation, and routing overhead are negligible.
- **>500ms** → parser is doing real work. Worth profiling [GeminiRecommendationParser](../sift/Services/GeminiRecommendationParser.swift).

### 5. SwiftData history fetch growth
- Look at: `swiftdata.historyFetch` over time (weeks).
- **Stable around 50–100ms** → no concern.
- **Growing linearly with session count** → will become a problem; add a fetch limit before it bites.

### 6. Whisper distinguishables
- `whisper.download` ≈ 0ms in run X, several seconds in run Y → run Y was a real download (first launch or model purge).
- `whisper.modelLoad` consistently >2s → disk-to-memory load is non-trivial; could be a candidate for warming on app launch ahead of the user tapping record.

---

## Hypotheses, ranked by suspicion

Each hypothesis lists the diagnostic signal that confirms or rejects it.

### H1. Silent Pro escalation (HIGH suspicion)
**Claim:** A meaningful fraction of sessions cross the 0.7 confidence threshold and pay for two sequential model calls (~12s + ~15s = ~27s).
**Confirmed by:** escalation rate >20%, OR a clearly bimodal `gemini.total` distribution.
**Cost to investigate:** zero — already in the data we'll collect.
**If confirmed:** see Experiments E1, E2.

### H2. Preview-endpoint latency overhead (MEDIUM-HIGH)
**Claim:** Both models are `-preview` variants, which often have lower priority and higher latency than GA endpoints.
**Confirmed by:** `gemini.flash` p50 > 4s in isolation (no escalation), high variance run-to-run.
**Cost to investigate:** swap to GA model name in a branch, re-run benchmark. ~30 min.
**If confirmed:** see Experiment E3.

### H3. Structured-output schema overhead (MEDIUM)
**Claim:** Forcing `responseMIMEType: application/json` + `responseSchema` ([GeminiRecommendationRouter.swift:151–156](../sift/Services/GeminiRecommendationRouter.swift:151)) can be meaningfully slower than free-form on Gemini, especially on flash-preview.
**Confirmed by:** schema-on vs schema-off A/B in the harness shows >20% latency reduction with schema off.
**Cost to investigate:** ~1 hour to write a schema-free variant of the parser, run benchmark.
**If confirmed:** see Experiment E4.

### H4. Prompt size / library enumeration (MEDIUM)
**Claim:** [GeminiPromptBuilder](../sift/Services/GeminiPromptBuilder.swift) enumerates the full practice library on every call. As the library grows, prompt tokens grow, and TTFT grows.
**Confirmed by:** count tokens on the current prompt; if >2k tokens for the library section alone, this is a meaningful chunk.
**Cost to investigate:** add a token-count log line; compare against benchmark with a 5-practice library.
**If confirmed:** see Experiment E5.

### H5. Lack of streaming (independent — about perceived latency, not actual)
**Claim:** The current call awaits the full response before transitioning to `.suggesting`. Even at 8s actual, this *feels* much longer than streaming would.
**Confirmed by:** orthogonal — streaming is a UX win regardless of the latency story.
**Cost to investigate:** N/A — confirmed worth doing once latency data is in.
**If pursued:** see Experiment E7.

### H6. Whisper transcribe slower than expected (LOW–MEDIUM)
**Claim:** Out of scope per user, but if `whisper.transcribe` p95 > 5s, it might be quietly contributing to the perceived "analysis is slow" story even though the user is mentally bucketing it as transcription.
**Confirmed by:** instrumentation will already tell us.
**Cost to investigate:** zero, the data is being collected.

### H7. Parser / schema validation cost (LOW)
**Claim:** Time spent inside [GeminiRecommendationParser.parse](../sift/Services/GeminiRecommendationParser.swift) on the critical path.
**Confirmed by:** `gemini.total - gemini.flash - gemini.pro` >500ms.
**Cost to investigate:** trivial once we have the data.

---

## Experiment matrix

Each experiment is a small, isolated change designed to test one hypothesis. Run against the harness with a stable fixture set; record before/after distributions.

| ID | Lever | Change | Expected to move | Risk to recommendation quality |
|----|----|----|----|----|
| **E1** | Threshold | `confidenceThreshold: 0.7 → 0.5` | Fewer escalations → big total drop on bimodal cases | Some "low confidence" recs ship without Pro reviewing |
| **E2** | No escalation | Always trust Flash, never call Pro | Eliminates Pro tail entirely | Worst case for quality on hard sessions |
| **E3** | GA model | `gemini-3-flash-preview` → current GA flash | Per-call latency, possibly large | Different model behavior, may need prompt tweaks |
| **E4** | No schema | Drop `responseSchema`, parse JSON loosely | Per-call latency on Gemini side | Parser becomes more lenient; schema drift risk |
| **E5** | Trim library | Send top-K practices (keyword/embedding) instead of all | Prompt size / TTFT | Wrong practices not even considered |
| **E6** | Reduce `maxOutputTokens` | 4096 → 1024 | Per-call latency (less to generate) | Truncation if rationale runs long |
| **E7** | Streaming | Use `generateContentStream`, progressive UI | Perceived only, not total | UI work; partial-state UX needs design |
| **E8** | Context caching | Cache system prompt + library via Gemini caching | Per-call latency on warm cache | Pricing model on cached content |
| **E9** | Speculative parallel | Fire Flash and Pro simultaneously when prior sessions suggest likely escalation | Wall-clock for would-be escalations | Doubles API cost on those sessions |
| **E10** | Smaller Whisper variant | `openai_whisper-base.en` → `tiny.en` | Whisper transcribe time | Transcription accuracy |

---

## Decision rules — what to try first based on the data

This section is the heart of the doc. When the metric history is in front of you, walk down this list:

1. **If escalation rate > 30%:** Run **E1** first (lower threshold). Cheapest possible change. If recommendation quality holds, ship and re-measure. If it tanks, try **E2** with a quality-conscious eye, or accept escalations and look at **E9** (parallel speculative).

2. **If escalation rate < 10% AND Flash p50 > 5s:** Escalation isn't the issue. Run **E3** (GA model) and **E4** (no schema) as a 2x2 in the harness. The faster combo wins. If both fail to move latency, the bottleneck is genuinely on Gemini's side and we should look at **E7** (streaming) for perceived-latency improvement.

3. **If Flash latency is fine (p50 < 3s) but variance is huge (p95 > 12s):** Server-side variance. Limited options. **E7** (streaming) is the right user-facing fix; **E9** (parallel speculative) helps if escalation is involved in the slow tail.

4. **If `gemini.total - flash - pro` > 500ms:** Look at the parser before any Gemini-side experiments. Local cost we control; almost certainly fixable.

5. **If prompt token count > 3k tokens:** Run **E5** (library trim). The library was always going to be a scaling pressure; might as well front-run it.

6. **If `swiftdata.historyFetch` is creeping up:** Independent of Gemini. Add a `fetchLimit` of e.g. 20 sessions on the history fetch. One-line change.

7. **If `whisper.transcribe` is the actual culprit (>5s p95) and the user re-scopes the investigation:** **E10** (tiny.en variant) is the obvious first lever, with an accuracy spot-check.

---

## Streaming as a non-mutually-exclusive concern

E7 is worth treating separately from the latency-reduction experiments because it changes the *experience* without necessarily changing the numbers. Even if E1–E5 successfully drop wall-clock to 6s, streaming the rationale as it generates would feel materially better than 6s of spinner. If the latency experiments only drop wall-clock to 10s, streaming becomes essential.

Recommended sequencing: chase latency first (cheap, well-defined), pursue streaming second (UI design work, more involved), don't conflate the two.

---

## Open threads not yet pulled on

Things noticed during exploration that weren't fully investigated. Worth a future look:

- **MetricRecorder lifecycle:** singleton vs `@Environment`-injected. Affects testability of the metric pipeline itself. Decide during the proposal.
- **What "gemini.total" includes:** Should it wrap the parser cost or just the network call? Currently undecided. Recommendation: wrap the whole `recommend()` so the user-facing total is captured, and let the per-phase metrics break out the inside.
- **Prompt warming / context caching:** Gemini supports explicit context caching via the API. The system prompt + practice library is identical across calls — strong cache candidate. Separate cost model on Google's side; worth a focused investigation.
- **Wake-on-record warming:** `loadModel()` could be triggered earlier (e.g. when the user opens the app, not when they hit record), so the first transcription doesn't pay model-load cost on the critical path. Trades cold-start time for hot-path responsiveness. Easy experiment.
- **Practice library YAML hot-reload:** [PracticeLibrary](../sift/Services/PracticeLibrary.swift) caches after first read but the first read is on the critical path. Pre-loading on app launch is trivial.
- **Bimodal vs long-tail distribution:** Whether the slow sessions cluster around one specific cause or are scattered. The shape of the `gemini.total` histogram on the debug screen will tell us a lot.

---

## How to run the benchmark harness

The active benchmark lives at [siftTests/GeminiBenchmark.swift](../siftTests/GeminiBenchmark.swift). It is gated by an environment variable so ordinary test runs and CI do not consume Gemini API credits.

To run:

1. In Xcode: Edit Scheme → Test → Arguments → Environment Variables.
2. Add `GEMINI_API_KEY` with your API key as the value.
3. Run the `benchmarkGeminiRecommend` test (or run the full test suite — only this test consumes credits).
4. Console output lines prefixed with `BENCHMARK` are parseable: `BENCHMARK iter=N ms=… model=… conf=… escalated=…`.

The benchmark intentionally does **not** persist its events to the SwiftData metric store, so it will not skew the percentiles on the in-app debug screen.

## What this doc is **not**

- A commitment to any specific experiment.
- A prediction of which hypothesis will win.
- A plan that obligates us to run all experiments.

It exists so the next session can open this file, look at fresh metric data, and immediately know which experiment to run first instead of re-deriving everything from scratch.
