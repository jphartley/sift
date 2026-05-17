## ADDED Requirements

### Requirement: Recommendation prompts include intake profile context
The system SHALL include the persisted user practice profile in Gemini recommendation prompts when profile context exists. The prompt SHALL distinguish hard constraints from soft recommendation priors. The prompt SHALL instruct Gemini that hard constraints must not be violated unless the current check-in clearly and specifically requests an exception.

#### Scenario: User profile exists
- **WHEN** the system builds a Gemini recommendation prompt for a user with a persisted practice profile
- **THEN** the prompt SHALL include the user's hard constraints, soft priors, desired support areas, practice history signals, language preferences, evidence preference, and relevant coaching style preferences
- **THEN** the prompt SHALL label hard constraints separately from soft priors

#### Scenario: User profile does not exist
- **WHEN** the system builds a Gemini recommendation prompt for a user without a persisted practice profile
- **THEN** the prompt SHALL remain valid using the current transcript, bounded prior session history, and compact practice library metadata

### Requirement: Recommendation validation enforces intake hard constraints
The system SHALL validate Gemini recommendations against the persisted user practice profile before displaying suggestions. The system SHALL reject or recover from recommendations that violate hard constraints unless the current check-in clearly and specifically requests the constrained practice or framing.

#### Scenario: Secular-only user receives prayer-like recommendation
- **WHEN** the persisted profile contains a secular-only hard constraint
- **AND** Gemini recommends a prayer-like, devotional, or religiously framed practice without a clear current-check-in override
- **THEN** the system SHALL not display that recommendation as a valid suggestion
- **THEN** the system SHALL recover by requesting or selecting a compliant alternative, or by surfacing an appropriate error state if no compliant alternative is available

#### Scenario: Current check-in clearly overrides a boundary
- **WHEN** the persisted profile contains a secular-only hard constraint
- **AND** the current check-in clearly asks for a mantra, prayer, or other previously constrained practice style
- **THEN** the system MAY allow a recommendation matching the current request
- **THEN** the recommendation rationale SHALL make the fit understandable without exposing internal constraint mechanics

#### Scenario: User explicitly excluded a practice family
- **WHEN** the persisted profile contains a hard constraint excluding a practice family
- **AND** Gemini recommends a practice from that family without a clear current-check-in override
- **THEN** the system SHALL not display that recommendation as a valid suggestion

### Requirement: Recommendation ranking uses intake soft priors
The system SHALL use intake soft priors to guide recommendation ranking without treating them as absolute exclusions. Soft priors SHALL affect prompt guidance and recommendation acceptance thresholds where applicable.

#### Scenario: User says breathwork helped sometimes
- **WHEN** the persisted profile indicates breathwork helped sometimes or did not really help
- **THEN** the recommendation prompt SHALL tell Gemini to recommend breathwork only when the current check-in makes it unusually relevant
- **THEN** the system SHALL still allow breathwork recommendations when they satisfy profile constraints and current context strongly supports them

#### Scenario: User prefers short practices
- **WHEN** the persisted profile indicates a preference for short practices
- **THEN** the recommendation prompt SHALL prefer practices matching the user's duration preference
- **THEN** the system SHALL still allow longer practices when the current check-in strongly supports them and no hard duration constraint exists

### Requirement: Research-backed-only recommendations use explicit practice grounding
When the persisted profile contains a research-backed-only hard constraint, the system SHALL display only practices with explicit research grounding metadata. The system SHALL not rely on Gemini's unsupported judgment that a practice is research-backed.

#### Scenario: Research-backed-only profile exists
- **WHEN** the persisted profile requires research-backed practices
- **THEN** the recommendation prompt SHALL instruct Gemini to select only practices marked with explicit evidence grounding in the library metadata
- **THEN** local recommendation validation SHALL reject any recommended practice that lacks explicit evidence grounding metadata

#### Scenario: No evidence-grounded recommendations are available
- **WHEN** the persisted profile requires research-backed practices
- **AND** Gemini returns no valid recommendations with explicit evidence grounding
- **THEN** the system SHALL recover by requesting or selecting compliant alternatives, or by surfacing an appropriate error state if no compliant alternative is available

### Requirement: Recommendation prompts avoid direct trauma questioning
The system SHALL not ask the user direct trauma-sensitivity questions as part of recommendation prompting. The system SHALL use inferred safety-oriented preferences from the intake profile, such as avoiding closed-eye, body-focused, intense, or inward-focused practices when indicated.

#### Scenario: Profile indicates body-focused practices should be avoided
- **WHEN** the persisted profile indicates the user wants to avoid body-focused practices
- **THEN** the recommendation prompt SHALL prefer practices that do not require sustained body scanning or inward body attention
- **THEN** local recommendation validation SHALL treat explicitly avoided body-focused practices as constrained when the profile marks them as a hard constraint
