# Mutation testing — exploration notes

Date: 2026-05-14
Status: **Explored, not pursued.** Closing as dead end for now.

## Motivation

Wanted to learn the concept of mutation testing. Initial targets were the
two files most likely to hide bugs that line coverage wouldn't catch:

- `sift/Services/GeminiRecommendationRouter.swift` — the `0.7` confidence
  threshold at line 50 (`if flashResult.confidence >= Self.confidenceThreshold`).
- `sift/Services/GeminiRecommendationParser.swift` — the silent `compactMap`
  drops at lines 42-48 (practices missing `practice_id` or `relevance` are
  dropped with no telemetry).

Intent was on-demand, not CI. Run roughly every 20 commits or when curious
about test quality. Never gating builds.

## Tool landscape (May 2026)

| Tool | Status | Verdict |
|---|---|---|
| `muter` | Actively maintained, last commit Apr 27 2026 | Only viable Swift-specific option |
| `mull-swift` (LLVM-based) | Stalled experiment from 2018 | Not production |
| Stryker | JS/TS/C#/Scala | No Swift port |
| PIT | Java/JVM | Irrelevant |

Muter is effectively the only game in town for Swift.

## Why muter is a dead end for this project

The `siftTests/` target is 100% on Swift Testing (`import Testing`, `@Test`
macros), not XCTest. As of May 2026, muter has:

- **Zero** mentions of Swift Testing in README.
- **Zero** mentions in release notes (last 5 releases).
- **Zero** commits referencing swift-testing / @Test.
- **Zero** GitHub issues raising the topic.

Muter detects test pass/fail by running `xcodebuild test` and parsing
output. The detection mechanism is undocumented in the README. If muter
relies on exit code, Swift Testing works fine. If it scrapes XCTest log
lines, every mutant on a Swift-Testing-only project will be misreported —
likely all "killed" (or all "survived"), and the results would be
meaningless without giving any error.

There is no way to verify this without running it. Community signal is
silent — either it works invisibly or nobody has migrated yet and hit the
issue. Either way, the risk profile for a learning exercise is bad:
non-trivial chance of spending hours wiring muter only to discover its
output is wrong, with no clear remediation path.

## Alternative paths considered

- **Path A — Smoke test muter first.** 30-60 min to install + point at a
  trivial target with a deliberately failing test. Validates compatibility
  before scaling. Risk: tool-wiring time crowds out actual learning.
- **Path B — Hand-roll a mini mutator (~100 LOC).** Swift/shell script
  that applies a textual mutation to a file, runs `xcodebuild test`,
  records pass/fail, restores. Deepest learning value (you implement the
  concept). Reusable on demand. Cost: 3-4 hours.
- **Path C — Manual mutation, no tool.** Edit each target file by hand
  (`>=` → `>`, comment out the `guard let`, etc.), run the suite, observe,
  restore. ~30 min. Maximum concept-per-minute. Not repeatable as a
  practice.

## Predicted findings (not validated)

If we *had* run mutation testing on the two target files, the most likely
survivors would be:

- Router: `confidence >= 0.7` → `confidence > 0.7` survives unless a test
  pins exactly `confidence = 0.7`. Boundary blindness.
- Parser: removing `guard let id = practice.practiceID` likely survives,
  because no test asserts "exactly N of M practices came through when one
  has a missing field." The `compactMap` drops are silent — that's
  arguably the real bug, not a test-coverage issue.

These two findings can be acted on directly without any mutation testing
tooling — write the boundary test on the router, and decide whether the
parser should log/surface dropped practices instead of silently filtering.

## Decision

Not pursuing mutation testing in this codebase right now. Re-evaluate if:

- Muter (or another tool) adds explicit Swift Testing support.
- The codebase grows large enough that automated mutation testing's
  value-per-hour exceeds the tooling friction.
- A specific bug slips through tests in a way that suggests systematic
  test-quality gaps, not just one missed case.

If the curiosity returns, Path B (hand-rolled, ~100 LOC) is the most
self-contained way to scratch the itch without depending on an external
tool's compatibility story.

## Sources

- [muter on GitHub](https://github.com/muter-mutation-testing/muter)
- [muter releases](https://github.com/muter-mutation-testing/muter/releases)
- [LLVM-based mutation testing for Swift — Swift Forums](https://forums.swift.org/t/llvm-based-mutation-testing-for-swift/45444)
- [Scaling Mutation Testing in a Large iOS Codebase](https://ericsspace.com/articles/scaling-mutation-testing-in-a-large-ios-codebase/)
- [Your Swift Tests Are Great. Until a Mutant Shows Up](https://codingwithkonsta.substack.com/p/your-tests-are-great-until-a-mutant)
