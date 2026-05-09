## 1. Safety Copy

- [x] 1.1 Replace the Privacy tab Safety placeholder with soft, relational safety guidance covering Sift's role, non-therapy boundary, user agency, and urgent support.
- [x] 1.2 Refine the Practice detail safety note so high-intensity and avoid-when practices tell users they can go slowly, adapt, or stop.

## 2. Tests

- [x] 2.1 Update Privacy content tests to cover the expanded Safety section and urgent-support language.
- [x] 2.2 Add or update Practice detail tests to cover high-intensity and avoid-when agency language.
- [x] 2.3 Update UI smoke or presentation-data tests if needed so the Safety section remains reachable from the Privacy tab.

## 3. Verification

- [x] 3.1 Run focused tests for Privacy and Practice detail safety behavior.
- [x] 3.2 Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [x] 3.3 Perform a scoped cleanup pass and check whether `AGENTS.md` needs updates.
- [x] 3.4 Validate OpenSpec artifacts for `add-emotional-safety-boundaries`.
