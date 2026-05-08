## Context

The app currently expects a `Secrets.geminiApiKey` symbol at compile time. The committed repo includes `sift/Services/Secrets.swift.example`, while the real `Secrets.swift` is ignored by git. That keeps keys safe, but it means a fresh clone may not compile until the developer discovers and creates the ignored file.

The existing runtime behavior is good: Gemini requests should fail with `GeminiError.apiKeyMissing` when no real key is configured. The missing piece is a safe default definition plus clear setup documentation.

## Goals / Non-Goals

**Goals:**
- Allow the app and tests to compile from a fresh clone without a private `Secrets.swift`.
- Preserve the existing runtime missing-key error when no real Gemini key is configured.
- Keep real keys out of git.
- Document first-run local setup clearly.
- Remove the completed tech-debt item after implementation.

**Non-Goals:**
- Add secret management infrastructure, keychain storage, or environment loading.
- Commit a real API key.
- Validate Gemini keys at app launch.
- Change Gemini model routing, prompt construction, or recommendation behavior.

## Decisions

### Commit a safe placeholder `Secrets` definition

Add a checked-in source file that defines `Secrets.geminiApiKey` as an empty string by default. This gives Swift a symbol to compile against while preserving the existing `GeminiService` guard that throws `GeminiError.apiKeyMissing` before making network calls.

Alternative considered: keep requiring developers to copy `Secrets.swift.example`. That preserves the current behavior but does not solve fresh-clone build failures.

### Keep local real keys in ignored overrides

Continue ignoring the real local secret file. If the project cannot safely have both a checked-in fallback and an ignored file with the same type name, adjust the naming pattern so the checked-in fallback can be edited locally or so the ignored local file provides only the key value without duplicate declarations.

Alternative considered: read the key from build settings or environment variables. That is more machinery than this MVP needs and would be harder for a non-CI local project to explain.

### Document setup in repo docs

Add concise first-run setup instructions in a repo-visible document, preferably a root `README.md` if none exists, or a focused docs file linked from existing docs. The instructions should explain that the app builds without a key, but real Gemini recommendations require adding a local key.

Alternative considered: only update `Secrets.swift.example`. A template helps, but it is easy to miss without first-run documentation.

## Risks / Trade-offs

- Duplicate `Secrets` definitions could break compilation if the fallback and local ignored file both declare the same type -> choose a file/naming pattern that avoids duplicate declarations.
- An empty fallback makes the app compile but not produce real Gemini recommendations -> preserve the explicit missing-key error and document this behavior.
- Local setup docs can drift -> keep instructions short and tied to the actual file names used by the implementation.
