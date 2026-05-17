## ADDED Requirements

### Requirement: Test suite can be invoked without a simulator
The automated test documentation SHALL include a macOS/Catalyst invocation as the preferred fast-feedback command.

#### Scenario: AGENTS.md documents the Catalyst test command
- **WHEN** a developer reads the Build & run section of AGENTS.md
- **THEN** they SHALL find a `xcodebuild test` command targeting `platform=macOS,variant=Mac Catalyst`

#### Scenario: docs/testing.md documents expected Catalyst run time
- **WHEN** a developer reads the Running tests section of docs/testing.md
- **THEN** they SHALL find the Catalyst destination command alongside the existing simulator command
