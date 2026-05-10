## Context

External TestFlight review exposes app metadata that may have been invisible during local development: the installed app name, microphone permission prompt, version/build values, and tester/reviewer instructions. Sift already has the product experience ready for trusted beta users, but the project still contains prototype-era microphone copy and lacks an explicit release-prep checklist.

## Goals / Non-Goals

**Goals:**

- Make the microphone permission prompt truthful, plain, and aligned with privacy copy.
- Ensure the installed app presents as `Sift`.
- Make build/version readiness explicit before the first external TestFlight upload.
- Keep real Gemini secret handling manual and uncommitted.
- Add local verification for metadata that can be checked without App Store Connect access.

**Non-Goals:**

- Automating App Store Connect upload, TestFlight review, tester invitations, or WhatsApp outreach.
- Committing a real Gemini API key.
- Changing recommendation, transcription, persistence, or privacy-tab runtime behavior.
- Creating App Store listing screenshots or production App Store marketing copy.

## Decisions

- Use generated Info.plist build settings rather than adding a separate Info.plist file. The project already uses `GENERATE_INFOPLIST_FILE = YES`, so the smallest aligned change is to update build settings directly.
- Set `INFOPLIST_KEY_CFBundleDisplayName = Sift` for app build configurations. This controls the installed display name without renaming the target or bundle identifier.
- Replace the microphone usage string with wording that explains the actual purpose: recording a voice check-in so Sift can transcribe it on device.
- Treat working Gemini key verification, Release archive upload, and real-device TestFlight smoke testing as manual checklist items in `docs/backlog.md`, because they depend on local secrets, signing, App Store Connect, and physical devices.
- Prefer a lightweight metadata test or static check that reads the Xcode project file, because these settings are project metadata rather than runtime Swift behavior.

## Risks / Trade-offs

- Project-file tests can be a little brittle if Xcode rewrites build settings. Mitigation: assert stable user-facing values rather than exact file structure.
- Build numbers still need to be bumped manually for later uploads. Mitigation: document the check clearly in the release checklist.
- A working Gemini key cannot be verified in committed tests without exposing secrets. Mitigation: keep existing safe-secret tests and add a manual pre-upload check; a separate beta key remains optional for the trusted beta.
