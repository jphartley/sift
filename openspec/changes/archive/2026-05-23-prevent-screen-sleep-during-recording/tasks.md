## 1. Specification and lifecycle wiring

- [x] 1.1 Add the `voice-check-in` delta spec covering active-recording screen wake behavior and cleanup.
- [x] 1.2 Introduce a small screen-idle control abstraction or equivalent lifecycle hook for the recording flow.

## 2. Recording flow implementation

- [x] 2.1 Enable screen-awake behavior only after recorder startup succeeds and recording becomes active.
- [x] 2.2 Restore normal idle behavior on stop, teardown, and any failed startup or permission-denied path.
- [x] 2.3 Ensure the new behavior does not extend into transcription, analysis, or suggestion states.

## 3. Tests and verification

- [x] 3.1 Add or update unit tests for the recording lifecycle to prove the wake lock is enabled and released on the correct transitions.
- [x] 3.2 Add or update teardown and failure-path tests so the screen-awake state cannot leak across exits.
- [x] 3.3 Run the standard Mac Catalyst test command and confirm the existing test suite still passes.
