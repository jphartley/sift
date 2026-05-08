## Why

A fresh clone can fail to build because production code references `Secrets.geminiApiKey`, while the real `Secrets.swift` file is intentionally gitignored and only `Secrets.swift.example` is committed. This slows setup and makes the local secret requirement easy to miss.

## What Changes

- Add a checked-in, debug-safe `Secrets` definition that lets the app compile without a private API key file.
- Keep real API keys out of version control and preserve the existing missing-key runtime error when no key is configured.
- Update first-run documentation so a developer knows how to add a local Gemini API key for real recommendation calls.
- Keep `Secrets.swift.example` as a clear template, or update it if the fallback changes the recommended setup.
- Add tests or build coverage proving the project compiles and the missing-key path remains explicit without a real key.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `gemini-practice-recommendation`: Clarify that the app must compile from a fresh clone with a safe placeholder key while still requiring a local key for real Gemini requests.
- `automated-tests`: Cover the compile-safe local secret fallback and missing-key behavior.

## Impact

- Affected files likely include `sift/Services/Secrets.swift` or a similarly named checked-in fallback, `sift/Services/Secrets.swift.example`, first-run documentation, `GeminiServiceTests`, and `docs/tech-debt.md`.
- No new package dependencies are expected.
- Real API keys remain gitignored.
- Runtime behavior remains unchanged for configured keys and should continue to fail at the first Gemini request when no key is configured.
