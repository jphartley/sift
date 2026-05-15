## ADDED Requirements

### Requirement: Benchmark harness is opt-in via environment variable

The system SHALL provide a Swift Testing benchmark file at `siftTests/GeminiBenchmark.swift` that exercises `GeminiService.recommend(...)` against the live Gemini API. Each benchmark test SHALL skip itself unless the `GEMINI_API_KEY` environment variable is present in the process environment, so that ordinary test runs and CI runs do not consume API credits.

#### Scenario: Benchmark runs without GEMINI_API_KEY in environment

- **WHEN** a benchmark test runs and `ProcessInfo.processInfo.environment["GEMINI_API_KEY"]` is nil
- **THEN** the test SHALL skip via Swift Testing's skip mechanism (e.g. `try #require(... != nil)`)
- **THEN** no Gemini API request SHALL be made

#### Scenario: Benchmark runs with GEMINI_API_KEY in environment

- **WHEN** a benchmark test runs and `GEMINI_API_KEY` is set
- **THEN** the test SHALL invoke `GeminiService.recommend(...)` against the live Gemini API using the provided key

### Requirement: Benchmark harness uses stable fixture transcripts

The system SHALL define a small fixed set of transcript fixtures used by the benchmark, so that re-runs against the same fixture produce comparable timing distributions. Fixtures SHALL be representative of typical user check-ins (a few sentences each, varied emotional themes) and SHALL be defined in source so the set is reproducible across machines and time.

#### Scenario: Multiple iterations run against the same fixture

- **WHEN** the benchmark runs N iterations with the same fixture transcript
- **THEN** each iteration SHALL receive identical input
- **THEN** any variance in timing SHALL be attributable to network and Gemini-side factors, not input differences

### Requirement: Benchmark harness emits parseable result lines per iteration

The system SHALL emit one line per iteration to standard output in a stable, parseable format containing at minimum: iteration index, measured duration in milliseconds, the model that responded (Flash or Pro), and the response confidence. The line format SHALL begin with a recognizable prefix (e.g. `BENCHMARK`) to enable simple grep-based extraction.

#### Scenario: Benchmark iteration completes successfully

- **WHEN** an iteration completes a `GeminiService.recommend(...)` call without error
- **THEN** the system SHALL print one line beginning with `BENCHMARK` containing the iteration index, duration in milliseconds, model identifier, and confidence value

#### Scenario: Benchmark iteration fails

- **WHEN** an iteration's `GeminiService.recommend(...)` call throws
- **THEN** the system SHALL fail the test with the underlying error
- **THEN** the system SHALL NOT emit a `BENCHMARK` success line for the failed iteration

### Requirement: Benchmark harness output is independent of MetricEvent persistence

The system SHALL NOT persist benchmark-iteration timings as `MetricEvent` rows in the SwiftData store used by the debug metrics screen. Benchmark output SHALL exist solely as console lines so that benchmark runs do not skew the percentile calculations on the debug metrics screen.

#### Scenario: Benchmark runs with the metrics screen also in use

- **WHEN** a benchmark run executes
- **THEN** the system SHALL NOT add `gemini.flash`, `gemini.pro`, or `gemini.total` events to the `MetricEvent` SwiftData store from within the benchmark
- **THEN** the debug metrics screen's percentile calculations SHALL remain based only on real-session events
