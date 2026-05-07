## Context

The practice library is a static array of 10 `Practice` structs in `PracticeLibrary.swift`. Each practice has an id, name, category, list of keywords, description, and duration. The full library is serialized into Gemini prompts for LLM-based recommendation.

The keyword matcher (`match(transcript:)`) was the original suggestion engine but has been fully supplanted by Gemini. It has zero production callers (only test references). The fact that it still exists is purely historical.

The user (sole developer) wants to expand the library significantly, edit it freely, and potentially have LLMs generate new practices. Editing Swift source code is not the right interface for content management.

## Goals / Non-Goals

**Goals:**
- Move all practice definitions from Swift source code to a YAML resource file bundled with the app
- Load practices at app launch via Yams, decode into the existing `Practice` struct
- Gracefully handle missing or malformed YAML with a clear error state
- Remove the unused keyword matcher (`match(transcript:)`)
- Enable easy editing by humans and LLMs, and remote delivery in the future

**Non-Goals:**
- Remote/OTA fetching of practices (bundled only for now; design must not preclude it)
- User-authored practices (still curated library for MVP)
- Dynamic practice addition at runtime
- Schema migration system for YAML format changes (file is small enough to just update in place)

## Decisions

### YAML over JSON or Property List

**Chosen: YAML + Yams**

| Factor | YAML | JSON | Property List (XML) |
|---|---|---|---|
| Multi-line descriptions | Clean block scalars (`description: \|`) | Awkward escaped strings | Verbose XML tags |
| Human readability | Highest — no quote noise, natural lists | Medium — quotes on all keys/strings | Lowest — XML boilerplate |
| LLM generation | Excellent — YAML is widely used in LLM training data | Excellent — JSON is also common | Poor — LLMs generate verbose/buggy XML |
| Dependencies | Yams (lightweight, ~2k GitHub stars, actively maintained) | None (built-in `JSONDecoder`) | None (built-in `PropertyListDecoder`) |
| Remote delivery fit | Excellent — YAML is standard for config over HTTP | Excellent — most CDNs serve JSON | Medium — plist is Apple-specific |
| Editing ergonomics | Best — bare keys, real newlines in descriptions, trailing commas allowed | Ok — no trailing commas, requires quoting | Worst — XML tags around every value |

JSON was the zero-dependency alternative. The BOM costs nothing in code (same `Codable`, same `Bundle` loading patterns), and the Yams dependency adds one line to `Package.swift`. The decisive factors were: (a) human readability for a file that will be edited often and grow large (~40+ practices), (b) multi-line description blocks that read naturally, and (c) LLM generation quality where YAML's block scalars avoid hallucinated escape characters.

### YAML file structure

```yaml
practices:
  - id: box-breathing
    name: Box Breathing
    category: Breathwork
    keywords:
      - breath
      - breathing
      - anxious
      - calm
      - stress
      - anxiety
      - nervous
    description: |
      Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4.
      Repeat 4 times.
    duration_minutes: 3
```

Key naming conventions:
- Root key: `practices` (a list)
- Snake_case for YAML keys (`duration_minutes`), decoded into camelCase Swift properties (`durationMinutes`) via `CodingKeys` enum
- Keywords as YAML list (more readable than inline `[a, b, c]`)
- Description uses YAML literal block scalar (`|`) for natural multi-line text

### Loading strategy

**Load at app launch, fail hard on error.**

The YAML file is loaded once at app launch (in `siftApp.swift` or via `@Observable` service initialization). If the file is missing or unparseable, the app enters an error state — this is a fatal error for the MVP because the app cannot suggest practices without the library. A fallback to a compiled-in default is unnecessary complexity given the file is bundled and validated at build time.

`Practice` becomes `Decodable` with `CodingKeys` to map snake_case YAML keys to camelCase Swift properties. A top-level wrapper struct (`PracticeLibrary`) holds the `practices` array for decoding.

```swift
struct PracticeLibrary: Decodable {
    let practices: [Practice]
}

struct Practice: Decodable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let category: String
    let keywords: [String]
    let description: String
    let durationMinutes: Int

    enum CodingKeys: String, CodingKey {
        case id, name, category, keywords, description
        case durationMinutes = "duration_minutes"
    }
}
```

Existing properties (id, name, category, keywords, description, durationMinutes) are preserved exactly. No schema changes to the Practice model.

### Removal of keyword matcher

`match(transcript:)` is removed entirely. The existing `PracticeLibraryTests.swift` tests for keyword matching are removed. Tests in `RecordingViewModelTests.swift` and `GeminiServiceTests.swift` that reference `Practice.all` are updated to decode from an in-memory YAML string (see test strategy below).

### Test strategy

Tests need access to practices without a file on disk. Two patterns:
1. **In-memory YAML strings**: Most tests will define a minimal YAML string inline and decode it directly via Yams. This avoids bundle dependency and keeps tests self-contained.
2. **Bundle resource**: Integration tests may load the real `practices.yaml` from the test bundle to validate it decodes correctly (full library validation).

Test helpers provide a convenience method:
```swift
static func practicesFromYAML(_ yaml: String) -> [Practice] { ... }
```

## Risks / Trade-offs

- **[Risk] Yams is a third-party dependency** → Mitigation: Yams is well-maintained (2k+ GitHub stars, active releases, CocoaPods/SPM/Carthage support). Pinned to a specific version in SPM.
- **[Risk] Malformed YAML at build time silently ships broken app** → Mitigation: Add a unit test that loads the bundled YAML and asserts it decodes without errors and has ≥ N practices. This catches format errors in CI and local test runs.
- **[Risk] `duration_minutes` snake_case mismatch** → Mitigation: `CodingKeys` enum is explicit and tested. YAML file and Swift struct must stay in sync — the bundle validation test catches drift.
- **[Trade-off] YAML is less strict than JSON** → Mitigation: Yams throws on malformed YAML just like JSONDecoder does. The type system (String, Int, [String]) enforces types. Extra keys are ignored by Codable by default (safe). A test validates the full file.

## Open Questions

- Should we pre-validate the YAML file at build time (run script phase) or rely solely on the runtime test? Runtime test is simpler and catches the same errors.
- What is the target practice count for the expanded library? (Informs file size and organization — single file is fine up to ~100 practices.)
