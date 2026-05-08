## 1. Secret Fallback

- [x] 1.1 Add a checked-in safe `Secrets.geminiApiKey` fallback that compiles without a private local key.
- [x] 1.2 Preserve a local-only path for configuring a real Gemini API key without committing it.
- [x] 1.3 Confirm `GeminiService` still throws `GeminiError.apiKeyMissing` before making a network request when the key is empty.

## 2. Documentation

- [x] 2.1 Add or update first-run setup documentation for local Gemini API key configuration.
- [x] 2.2 Update `Secrets.swift.example` if the recommended local setup file or shape changes.
- [x] 2.3 Remove the completed `Clarify local secret setup` entry from `docs/tech-debt.md`.

## 3. Tests

- [x] 3.1 Add or update tests proving `Secrets.geminiApiKey` is available without a private key file.
- [x] 3.2 Add or update tests proving an empty key returns the missing-key error before the Gemini requester is called.
- [x] 3.3 Run focused Gemini service tests.

## 4. Completion

- [x] 4.1 Run the full `xcodebuild test` suite.
- [x] 4.2 Perform the scoped cleanup pass.
- [x] 4.3 Check whether `AGENTS.md` needs architecture, dependency, or workflow updates.
- [x] 4.4 Validate the OpenSpec change.
