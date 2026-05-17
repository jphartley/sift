## ADDED Requirements

### Requirement: Unit tests run on macOS without a simulator
The system SHALL support running the `siftTests` unit test suite natively on macOS via the Mac Catalyst destination, with no iOS simulator required.

#### Scenario: Catalyst test invocation succeeds
- **WHEN** `xcodebuild test -destination 'platform=macOS,variant=Mac Catalyst' -only-testing:siftTests` is run
- **THEN** all unit tests SHALL pass with no simulator launched

#### Scenario: All 272 unit tests pass on macOS
- **WHEN** the Catalyst test run completes
- **THEN** the reported test count SHALL match the iOS Simulator test count
- **THEN** no tests SHALL be skipped due to platform incompatibility

### Requirement: iOS Simulator destination remains functional
The existing iOS Simulator test invocation SHALL continue to work unchanged after Catalyst is enabled.

#### Scenario: iOS simulator run still passes
- **WHEN** `xcodebuild test -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:siftTests` is run
- **THEN** all unit tests SHALL pass as before

### Requirement: Settings navigation is a no-op on macOS
On macOS/Catalyst, the microphone permission recovery action that opens iOS Settings SHALL compile and run without crashing, but SHALL perform no navigation.

#### Scenario: Settings action on macOS does not crash
- **WHEN** the settings recovery action is triggered on macOS/Catalyst
- **THEN** the app SHALL NOT crash
- **THEN** no system Settings navigation SHALL occur
