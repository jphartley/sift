## ADDED Requirements

### Requirement: Analysis latency experiments are independently switchable
The system MUST support a set of runtime-controlled analysis latency experiments that can be enabled and disabled independently. The supported experiments MUST be separable enough that enabling one experiment does not require enabling any other experiment.

The supported experiments for this change MUST be limited to Flash model selection, response schema strictness, prompt/context trimming, output token budget, confidence threshold, and disabling escalation.

#### Scenario: All experiments are disabled
- **WHEN** the app runs with all analysis latency experiments disabled
- **THEN** the analysis flow MUST preserve the current Flash-to-Pro recommendation behavior and prompt shape

#### Scenario: One experiment is enabled
- **WHEN** a single analysis latency experiment is enabled
- **THEN** only that experiment's behavior MUST change
- **AND** all other analysis latency behavior MUST remain at the baseline default

#### Scenario: Multiple experiments are enabled
- **WHEN** multiple analysis latency experiments are enabled together
- **THEN** the system MUST apply the enabled experiments independently
- **AND** the active combination MUST be deterministic for the duration of the check-in

#### Scenario: Future experiments are out of scope
- **WHEN** a developer views the analysis latency experiment controls
- **THEN** the controls MUST NOT expose streaming, context caching, or speculative parallelization toggles
- **AND** those future experiments MUST require separate changes before they can affect analysis behavior

### Requirement: Analysis latency experiment state is observable
The system MUST record the active analysis latency experiment state alongside analysis timing data so benchmark results and debug views can attribute performance to the active configuration.

#### Scenario: A timing sample is recorded
- **WHEN** the analysis phase records a timing sample
- **THEN** the recorded data MUST include the active experiment identifiers or an equivalent compact representation

#### Scenario: The active configuration is visible in debug tooling
- **WHEN** a developer views the debug tab
- **THEN** the tab MUST show a label for each active analysis latency experiment
- **AND** the current experiment configuration MUST be distinguishable from baseline runs
- **AND** the experiment controls MUST NOT obscure the metric summaries by default

#### Scenario: The debug tab is filtered by experiment label
- **WHEN** a developer filters the debug tab by an experiment label
- **THEN** the tab MUST narrow the visible debug content to matching experiment entries
- **AND** the filter MUST support at least one active experiment label at a time
- **AND** the filter control MUST be presented with the metric results rather than inside the experiment switch panel

#### Scenario: The experiment controls are opened from the debug tab
- **WHEN** a developer opens the experiment configuration controls
- **THEN** the full experiment switch panel MUST be available without removing metric summaries from the default debug view
- **AND** the developer MUST be able to return to the metrics view without leaving the debug tab
- **AND** metric lists MUST leave enough bottom scroll space to remain readable above the app tab bar

### Requirement: Experiment toggles are runtime controlled
The system MUST allow analysis latency experiments to be toggled without rebuilding the app.

#### Scenario: A toggle is changed between runs
- **WHEN** a developer or tester changes an analysis latency experiment toggle
- **THEN** the next analysis request MUST use the updated toggle state
- **AND** the app MUST not require a rebuild for the change to take effect
