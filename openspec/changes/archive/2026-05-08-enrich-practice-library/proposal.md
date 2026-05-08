## Why

The bundled practice library started as a small test fixture and is now too thin for the voice check-in MVP's recommendation loop. Sift needs richer, executable practice metadata so Gemini can make better recommendations and the UI can eventually guide users through a chosen practice.

## What Changes

- **BREAKING**: Replace the practice `description` field with richer canonical fields: `summary`, `steps`, `why_it_helps`, `labels`, `best_for`, `intensity`, and `avoid_when`.
- Expand the bundled YAML library with the first curated categories from the planning process: Breathwork, Meditation, Grounding, and Movement.
- Preserve one primary method-based `category` per practice while adding labels for needs, context, and qualities.
- Update Gemini prompt construction to include the richer recommendation metadata.
- Update suggestion and reflection surfaces to use `summary` as the short app-facing practice text.
- Update tests and fixtures so bundled YAML decoding and schema expectations cover the richer library.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `yaml-practice-library`: Practice definitions now require richer executable metadata instead of a single description.
- `gemini-practice-recommendation`: Gemini prompts now include richer practice metadata for recommendation matching.
- `suggestion-interaction`: Practice cards and reflection context now display the practice summary in place of the old description text.

## Impact

- Affected files:
  - `sift/Resources/practices.yaml`
  - `sift/Models/PracticeLibrary.swift`
  - `sift/Services/GeminiPromptBuilder.swift`
  - `sift/Views/SuggestionView.swift`
  - `sift/ViewModels/RecordingViewModel.swift`
  - practice library, prompt builder, and recording view model tests
- No new runtime dependencies.
- Existing YAML entries must migrate to the new schema before decoding succeeds.
