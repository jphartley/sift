## 1. App Metadata

- [x] 1.1 Update the app target microphone usage description to explain voice check-ins and on-device transcription.
- [x] 1.2 Add the app target display name metadata so installed beta builds appear as `Sift`.
- [x] 1.3 Confirm app target marketing version and build number are explicit and ready for TestFlight upload.

## 2. Beta Operations Checklist

- [x] 2.1 Update `docs/backlog.md` to state that testers will be external TestFlight testers invited personally via WhatsApp.
- [x] 2.2 Add manual pre-upload checks for real Gemini API key configuration without committing secrets.
- [x] 2.3 Add manual release/device checks for Release build, TestFlight install, and full smoke-test loop.
- [x] 2.4 Add beta review note guidance that explains the reviewer path and wellness/non-crisis boundary.

## 3. Tests

- [x] 3.1 Add automated or static project metadata coverage for display name.
- [x] 3.2 Add automated or static project metadata coverage for microphone usage description.
- [x] 3.3 Add automated or static project metadata coverage for explicit marketing version and build number.

## 4. Verification

- [x] 4.1 Run focused metadata tests or static checks.
- [x] 4.2 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 4.3 Perform the scoped cleanup pass for dead code, unused imports, stale comments, and project-pattern alignment.
- [x] 4.4 Check whether `AGENTS.md` needs updates for this change.
- [x] 4.5 Run `openspec validate prepare-testflight-beta-metadata --strict`.
