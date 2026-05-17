## ADDED Requirements

### Requirement: Practice library includes evidence grounding metadata
The bundled YAML practice library SHALL include explicit evidence grounding metadata for each practice. The metadata SHALL allow the system to determine whether a practice is eligible for users who require research-backed-only recommendations.

#### Scenario: Practice has explicit evidence grounding
- **WHEN** a practice is supported by explicit research grounding
- **THEN** the YAML entry SHALL mark the practice as evidence-grounded
- **THEN** the YAML entry SHALL include compact evidence metadata suitable for prompt construction and local validation

#### Scenario: Practice lacks explicit evidence grounding
- **WHEN** a practice does not have explicit research grounding in the catalogue
- **THEN** the YAML entry SHALL not mark the practice as eligible for research-backed-only recommendations
- **THEN** the practice SHALL remain available for users without a research-backed-only constraint when it otherwise fits

### Requirement: Practice decoding supports evidence metadata
The Practice struct SHALL decode evidence grounding metadata from the YAML library. Practice decoding SHALL remain deterministic and SHALL expose evidence eligibility to Gemini prompt construction and recommendation validation.

#### Scenario: Practice decodes evidence metadata
- **WHEN** a YAML practice entry contains evidence grounding metadata
- **THEN** the system SHALL decode that metadata into the Practice representation
- **THEN** prompt construction and recommendation validation SHALL be able to read whether the practice is eligible for research-backed-only users

#### Scenario: Bundled library validation runs
- **WHEN** the practice library validation tests run
- **THEN** the tests SHALL assert every bundled practice has explicit evidence metadata
- **THEN** the tests SHALL assert research-backed eligibility is unambiguous for every bundled practice

### Requirement: Practice metadata supports boundary and preference matching
The bundled practice library SHALL include compact metadata needed to match intake profile boundaries and priors. The metadata SHALL identify practice families, worldview or language framing where relevant, and presentation characteristics such as body-focused, closed-eye, breath-focused, devotional, or intense practices where applicable.

#### Scenario: Secular-only validation checks a practice
- **WHEN** local recommendation validation evaluates a practice for a secular-only user
- **THEN** the system SHALL be able to determine from practice metadata whether the practice is prayer-like, devotional, or religiously framed by default

#### Scenario: Practice-family validation checks a practice
- **WHEN** local recommendation validation evaluates a practice for a user who explicitly excluded a practice family
- **THEN** the system SHALL be able to determine from practice metadata whether the practice belongs to that excluded family

#### Scenario: Safety-oriented preference matching checks a practice
- **WHEN** prompt construction or local validation evaluates inferred preferences such as avoiding closed-eye, body-focused, breath-focused, or intense practices
- **THEN** the system SHALL be able to determine from practice metadata whether the practice has those presentation characteristics
