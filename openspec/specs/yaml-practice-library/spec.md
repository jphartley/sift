## Purpose
Define how the bundled YAML practice library is loaded, decoded, and validated.
## Requirements
### Requirement: System loads practices from YAML resource file

The system SHALL load wellness practice definitions from a bundled YAML resource file (`practices.yaml`) at app launch. Each practice SHALL have an id, name, category, labels, best-fit situations, keywords, summary, steps, why-it-helps explanation, duration in minutes, intensity, and neutral avoid-when guidance.

#### Scenario: YAML file loads successfully

- **WHEN** the app launches and the YAML file is present in the bundle
- **THEN** the system SHALL decode all practices into Practice structs
- **THEN** the decoded practices SHALL be accessible for Gemini prompt construction and practice display

#### Scenario: YAML file is missing from bundle

- **WHEN** the app launches and `practices.yaml` is not found in the bundle
- **THEN** the system SHALL enter an error state indicating the practice library could not be loaded
- **THEN** the app SHALL display an error message to the user

#### Scenario: YAML file contains malformed data

- **WHEN** the app launches and `practices.yaml` contains invalid YAML that cannot be decoded
- **THEN** the system SHALL enter an error state with a descriptive message
- **THEN** the app SHALL display an error message to the user

### Requirement: Practice struct supports YAML decoding

The Practice struct SHALL conform to Decodable with CodingKeys mapping snake_case YAML keys (e.g., `duration_minutes`, `best_for`, `why_it_helps`, `avoid_when`) to camelCase Swift properties (e.g., `durationMinutes`, `bestFor`, `whyItHelps`, `avoidWhen`).

#### Scenario: Practice decodes from valid YAML

- **WHEN** a YAML representation of a practice contains id, name, category, labels, best_for, keywords, summary, steps, why_it_helps, duration_minutes, intensity, and avoid_when
- **THEN** the system SHALL successfully decode it into a Practice struct with all fields populated

#### Scenario: YAML contains extra unknown keys

- **WHEN** a YAML representation includes a key not defined in the Practice struct's CodingKeys
- **THEN** the system SHALL ignore the unknown key and decode the practice without error

### Requirement: Practice library is validated at test time

The system SHALL include unit tests that load the bundled `practices.yaml` and assert it decodes without errors, contains practices, and includes non-empty required metadata for each bundled practice.

#### Scenario: Bundled YAML passes validation

- **WHEN** the validation test runs
- **THEN** the system SHALL decode the YAML file without throwing an error
- **THEN** the system SHALL assert the decoded practice list is non-empty
- **THEN** the system SHALL assert each decoded practice has non-empty keywords, labels, best-fit situations, summary, steps, why-it-helps explanation, and intensity

#### Scenario: Test catches malformed YAML

- **WHEN** a developer introduces a syntax error in `practices.yaml`
- **THEN** the validation test SHALL fail with a decoding error

### Requirement: Practice library includes enriched selected categories

The bundled practice library SHALL include enriched practices for all selected categories from the practice library planning process: Breathwork, Meditation, Grounding, Movement, Journaling, Emotional Processing, Social Connection, Nature, Creative Expression, Practical Care, Sleep & Wind-Down, Self-Compassion, Values & Intention, and Spiritual / Contemplative.

#### Scenario: Selected category practices are bundled

- **WHEN** the bundled YAML practice library is decoded
- **THEN** the resulting practice list SHALL include practices across all selected practice categories
- **THEN** those practices SHALL use the richer executable schema rather than the legacy description field

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
