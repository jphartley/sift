## 1. Flag plumbing and observability

- [x] 1.1 Add an analysis-latency experiment flag store with a default-off snapshot API that can represent independent flags for the Gemini-side slices.
- [x] 1.2 Thread the experiment snapshot through the Gemini request path and benchmark harness so each timing sample can be attributed to the active configuration.
- [x] 1.3 Surface the active experiment set in the debug metrics UI as one label per enabled experiment.
- [x] 1.4 Add label-based filtering to the debug tab so developers can narrow the visible experiment state to matching labels.
- [x] 1.5 Rework the debug tab so metric results remain visible by default and the full experiment switch panel opens separately.

## 2. Flash-path latency slices

- [x] 2.1 Add a flag for the Flash model variant and cover the preview-vs-stable selection behavior with tests.
- [x] 2.2 Add a flag for response schema strictness and cover schema-on vs schema-off behavior with tests.
- [x] 2.3 Add flags for prompt/context trimming and max output token budget, then cover each branch with prompt-builder and service tests.

## 3. Routing and execution slices

- [x] 3.1 Add a flag for the Flash confidence threshold and a flag to disable escalation entirely, with tests for the default and overridden routing paths.

## 4. Verification and cleanup

- [x] 4.1 Update the benchmark notes and any related docs to describe how to run and compare analysis-latency experiments.
- [x] 4.2 Run the relevant test suites for each slice, confirm the default-off path is unchanged, and remove any temporary logging or dead code introduced during the work.
