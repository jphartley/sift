## ADDED Requirements

### Requirement: Debug tab is available only in Debug-configuration builds

The system SHALL expose a "Debug" tab containing the metrics screen only when the app is built in Debug configuration. The tab SHALL be excluded from Release-configuration builds via a `#if DEBUG` compilation guard around the `TabView` that hosts it. When the Debug tab is excluded, the app SHALL render its existing root navigation unchanged.

#### Scenario: Debug build launches

- **WHEN** the app launches in Debug configuration
- **THEN** the system SHALL display a `TabView` with at least two tabs: the main application flow and a Debug tab
- **THEN** the Debug tab SHALL be reachable via standard `TabView` navigation

#### Scenario: Release build launches

- **WHEN** the app launches in Release configuration
- **THEN** the system SHALL NOT display a tab bar
- **THEN** the system SHALL render the existing main application root view directly

### Requirement: Debug metrics screen displays summary statistics per metric name

The system SHALL provide a `DebugMetricsScreen` that, when opened, displays one row per distinct metric name found in the persisted `MetricEvent` store. Each row SHALL display the metric name, the count of events recorded under that name, the median (p50) duration in milliseconds, the 95th percentile (p95) duration in milliseconds, and the duration of the most recent event under that name. The summary view SHALL also display a top-level "Escalations" indicator showing the number of `gemini.pro` events as a fraction and percentage of `gemini.flash` events.

#### Scenario: User opens the debug metrics screen with recorded events

- **WHEN** the user opens the Debug tab and there are persisted `MetricEvent` rows
- **THEN** the system SHALL display one row per distinct metric name
- **THEN** each row SHALL display name, count, p50 ms, p95 ms, and last-event ms

#### Scenario: User opens the debug metrics screen with no recorded events

- **WHEN** the user opens the Debug tab and no `MetricEvent` rows exist
- **THEN** the system SHALL display an empty-state message indicating no metrics have been recorded yet

#### Scenario: Escalation pill reflects current Pro/Flash event ratio

- **WHEN** the summary view renders
- **THEN** the system SHALL compute and display the count of `gemini.pro` events, the count of `gemini.flash` events, and the percentage ratio
- **THEN** if no `gemini.flash` events exist, the system SHALL display the pill in a neutral "no data" state rather than dividing by zero

### Requirement: Debug metrics screen supports drill-down into raw events per metric

The system SHALL allow the user to tap any row in the summary view to navigate to a detail view for that metric. The detail view SHALL list all persisted events for the selected metric in reverse chronological order, displaying for each event: timestamp, duration in milliseconds, and any metadata. Events whose duration exceeds the p95 of recent events for that metric SHALL be visually highlighted as outliers.

#### Scenario: User taps a metric row to see raw events

- **WHEN** the user taps a row in the summary view
- **THEN** the system SHALL navigate to a detail view scoped to the selected metric name
- **THEN** the detail view SHALL list events in reverse chronological order with timestamp, duration, and metadata

#### Scenario: An event exceeds the p95 outlier threshold

- **WHEN** an event's duration exceeds the p95 of recent events for the same metric
- **THEN** the system SHALL visually distinguish that event in the detail view (e.g. text color, icon, or label)

### Requirement: Debug metrics screen provides a clear-all action

The system SHALL provide a "Clear all" action on the debug metrics screen that, when invoked, deletes all persisted `MetricEvent` rows after a confirmation prompt. Other entities (`Session`, `PracticeAttempt`) SHALL NOT be affected.

#### Scenario: User clears all metrics

- **WHEN** the user invokes "Clear all" and confirms
- **THEN** the system SHALL delete every `MetricEvent` row from SwiftData
- **THEN** the system SHALL leave all other SwiftData entities unchanged
- **THEN** the summary view SHALL re-render in its empty state

### Requirement: Debug metrics screen exposes an onboarding reset section

The system SHALL display a dedicated "Onboarding" section in `DebugMetricsScreen` containing a "Reset onboarding" button. The section SHALL appear below the experiments and metrics content. The button SHALL be enabled at all times regardless of whether any `UserPracticeProfile` records exist. Tapping the button SHALL present a confirmation dialog before any deletion is performed.

#### Scenario: User views the debug metrics screen

- **WHEN** the user opens the Debug tab
- **THEN** the system SHALL display an "Onboarding" section containing a "Reset onboarding" button
- **THEN** the button SHALL be enabled regardless of current profile state

#### Scenario: User taps Reset onboarding

- **WHEN** the user taps the "Reset onboarding" button
- **THEN** the system SHALL present a confirmation dialog asking "Reset onboarding?"
- **THEN** the dialog SHALL include a destructive "Reset" action and a "Cancel" action
