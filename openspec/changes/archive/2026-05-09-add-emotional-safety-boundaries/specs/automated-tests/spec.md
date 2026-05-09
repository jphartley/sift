## ADDED Requirements

### Requirement: Tests cover emotional safety guidance

The system SHALL have automated tests verifying that beta emotional-safety guidance is visible, plain-language, and soft in tone.

#### Scenario: Privacy safety copy is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that the Safety section states Sift is for reflection and practice suggestions
- **THEN** the tests SHALL verify that the Safety section states Sift is not a therapist, doctor, or crisis service
- **THEN** the tests SHALL verify that the Safety section gives users permission to pause, skip, adapt, or stop a practice
- **THEN** the tests SHALL verify that the Safety section mentions reaching out to someone they trust

#### Scenario: Urgent support copy is covered
- **WHEN** automated tests exercise the Privacy screen or its presentation data
- **THEN** the tests SHALL verify that the Safety section covers risk of hurting yourself or someone else
- **THEN** the tests SHALL verify that the Safety section covers not feeling safe
- **THEN** the tests SHALL verify that the Safety section mentions emergency support or a trusted person

### Requirement: Tests cover practice safety-note agency language

The system SHALL have automated tests verifying that contextual practice safety notes preserve user agency.

#### Scenario: High-intensity practice note is covered
- **WHEN** automated tests exercise practice detail presentation for a high-intensity practice
- **THEN** the tests SHALL verify that the safety note tells users to go slowly
- **THEN** the tests SHALL verify that the safety note says users can adapt or stop

#### Scenario: Avoid-when practice note is covered
- **WHEN** automated tests exercise practice detail presentation for a practice with avoid-when guidance
- **THEN** the tests SHALL verify that the safety note contains the avoid-when guidance
- **THEN** the tests SHALL verify that the safety note says users can adapt or stop
