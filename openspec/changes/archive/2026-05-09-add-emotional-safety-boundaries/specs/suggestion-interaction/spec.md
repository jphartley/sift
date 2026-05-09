## MODIFIED Requirements

### Requirement: Practice detail page shows calm safety note when needed

The system SHALL show a subtle, non-red safety note when the selected practice has non-empty avoid-when guidance or high intensity. The note SHALL use soft, relational language that reminds users they can go slowly, adapt, or stop. The note SHALL be omitted for low and medium intensity practices with no avoid-when guidance.

#### Scenario: Practice has avoid-when guidance
- **WHEN** the selected practice has one or more avoid-when values
- **THEN** the practice detail page SHALL show a calm note containing those values
- **THEN** the note SHALL communicate that the user can adapt or stop the practice

#### Scenario: Practice is high intensity
- **WHEN** the selected practice has high intensity
- **THEN** the practice detail page SHALL show a calm note indicating that it is a higher-intensity practice
- **THEN** the note SHALL tell the user to go slowly
- **THEN** the note SHALL communicate that the user can adapt or stop the practice

#### Scenario: Practice has no note-worthy guidance
- **WHEN** the selected practice is low or medium intensity and has no avoid-when values
- **THEN** the practice detail page SHALL omit the safety note
