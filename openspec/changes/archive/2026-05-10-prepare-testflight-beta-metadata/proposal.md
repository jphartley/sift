## Why

Before inviting external TestFlight testers, Sift should feel like a real beta app rather than a prototype build. The remaining codebase preparation is small but important: app metadata and permission copy should match the actual product experience, and manual release checks should be explicit.

## What Changes

- Update the microphone permission purpose string so it explains voice check-ins and on-device transcription in plain user-facing language.
- Set the app display name to `Sift` so the installed beta does not appear as lowercase `sift`.
- Prepare build/version metadata for TestFlight by ensuring the current marketing version and build number are explicit and ready to bump when needed.
- Add a simple release-readiness checklist covering working Gemini key verification, Release build/device smoke test, and external TestFlight review notes.
- Add lightweight automated coverage or scriptable checks for the project metadata that can be tested locally without App Store Connect access.

## Capabilities

### New Capabilities

- `testflight-beta-readiness`: Covers app metadata, user-facing permission copy, build/version readiness, and manual external TestFlight preparation checks.

### Modified Capabilities

- `automated-tests`: Adds coverage expectations for TestFlight-facing project metadata checks.

## Impact

- `sift.xcodeproj/project.pbxproj`
- `docs/backlog.md`
- Potential test or helper file under `siftTests/` if project metadata is exposed in a testable form.
- No App Store Connect API integration, no committed Gemini secret, and no change to runtime recommendation behavior.
