# Practice Library Expansion Plan

Planning note for expanding `sift/Resources/practices.yaml` from a small test list into a richer wellness practice library.

This document captures where the planning conversation paused, the methodology we agreed on, and the current shortlists. It is intentionally not an implementation spec yet. Once the taxonomy and sample practices feel solid, this can become an OpenSpec proposal.

## Product Direction

The practice library should become a set of small, executable wellness protocols, not just a list of suggestions.

The app should be able to recommend 3-4 practices after a voice check-in. Users will not browse the full library initially, so the library does not need equal category sizes. Recommendation quality matters more than editorial symmetry.

The library should support experienced users, while staying within a safe middle range. Stronger practices are acceptable when they are well labeled, but practices that imply clinical support, long facilitation, or deep trauma work are out of scope for now.

## Methodology

We are planning in layers:

1. Define high-level, method-based categories.
2. For each category, generate a broad candidate list.
3. Filter candidates down manually.
4. Later, enrich each selected practice with structured metadata.
5. Then create an OpenSpec proposal before implementation.
6. During implementation, migrate the model and tests from the old `description`-based schema to the richer schema.

The candidate generation style is:

- Mix canonical practices with warmer, Sift-flavored practices.
- Aim roughly for 3 canonical plus 2 warmer/original practices per category, but do not force the ratio.
- Let category sizes vary where some categories naturally have more strong options.
- Keep the practices intentional and tryable, not vague lifestyle advice.

## Agreed Category Model

Categories are method-based, not need-based.

Each practice has one primary category. Cross-cutting meaning, context, and user needs are represented through labels.

Current primary categories:

1. Breathwork
2. Meditation
3. Grounding
4. Movement
5. Journaling
6. Emotional Processing
7. Social Connection
8. Nature
9. Creative Expression
10. Practical Care
11. Sleep & Wind-Down
12. Self-Compassion
13. Values & Intention
14. Spiritual / Contemplative

## Scope Boundaries

The library should be broader than clinical wellness, but not excessively broad.

Good fits:

- Breathwork
- Meditation
- Grounding
- Journaling
- Movement
- Walking
- Gardening
- Making tea
- Tidying one surface
- Taking a shower
- Listening to music intentionally
- Creative expression
- Prayer or contemplative practice

Poor fits for now:

- Watching a movie
- Shopping
- General entertainment
- Large lifestyle projects
- Anything that feels like advice rather than a contained practice

Working rule:

> A Sift practice should be small, intentional, and reflective enough that the user can try it and then answer, "Did this help?"

## Intensity Boundaries

The app is aimed at fairly experienced users, so some stronger practices are acceptable.

Acceptable with clear labeling:

- Shaking
- Stronger breathwork
- Long meditation, capped around 30-40 minutes
- Cold exposure or cold water reset
- Bounded intense journaling

Out of scope for now:

- Holotropic breathwork
- Trauma release exercises
- Deep grief rituals
- Practices requiring a trained facilitator
- Practices implying a multi-hour altered-state container

## Duration

Practices may range from quick resets to deeper sessions.

Guidance:

- 1-3 minutes: emergency or transition reset
- 5-10 minutes: standard recommendation range
- 15-30 minutes: deeper practice
- 40 minutes: approximate upper cap

`duration_minutes` should describe the expected minimum useful dose, not an ideal maximum.

## Recommendation Diversity

Recommendation responses should strongly prefer category diversity, but this is not a hard rule.

Default:

- Recommend practices from different primary categories.

Allowed:

- Two practices from the same category when strongly relevant.

Explicit user intent:

- If the transcript clearly asks for one method, multiple or all suggestions can come from that category.
- Example: "I feel like I need to meditate now" can return three meditation practices.

This recommendation rule should eventually live in the Gemini prompt logic, not only in the YAML.

## Proposed Practice Schema

We agreed to migrate away from the current `description` field.

Target shape:

```yaml
- id: box-breathing
  name: Box Breathing
  category: Breathwork
  labels:
    - anxiety
    - calm
    - quick-reset
    - nervous-system
    - low-effort
  best_for:
    - racing thoughts
    - feeling physically keyed up
    - needing a quick reset before continuing
  keywords:
    - breath
    - breathing
    - anxious
    - calm
    - stress
    - nervous
  summary: A steady four-part breathing pattern for settling anxious activation.
  steps:
    - Sit upright or stand with your feet grounded.
    - Inhale through your nose for 4 seconds.
    - Hold gently for 4 seconds.
    - Exhale slowly for 4 seconds.
    - Hold empty for 4 seconds.
    - Repeat for 4-6 rounds, then breathe normally.
  why_it_helps: |
    The predictable rhythm gives your attention somewhere steady to land, while the slower pace can help your body move out of high alert.
  duration_minutes: 3
  intensity: low
  avoid_when:
    - driving
    - feeling dizzy
```

Field roles:

- `category`: one primary method bucket.
- `labels`: curated needs, context, and qualities; may become UI-visible later.
- `keywords`: messy transcript-matching language.
- `best_for`: human-readable matching situations.
- `summary`: warm, concise description of the practice.
- `steps`: direct second-person instructions the user can follow.
- `why_it_helps`: short, non-medical explanation.
- `duration_minutes`: expected useful dose.
- `intensity`: `low`, `medium`, or `high`.
- `avoid_when`: neutral safety/context guidance.

Fields deliberately skipped for now:

- `tone`
- `experience_level`

## Voice and Content Style

Summaries should be warm and non-clinical.

Steps should be direct, second-person, and executable.

`why_it_helps` should be gentle and explanatory. It should avoid overclaiming or sounding medical.

External content is allowed, but should not be embedded. For example, a practice may ask the user to choose a sacred text, poem, song, or guided resource, but the YAML should not include copyrighted text or long quoted material.

## Spiritual / Contemplative Guidance

Tradition-specific practices are allowed.

Guidelines:

- Name practices and traditions respectfully.
- Avoid flattening sacred practices into productivity tools.
- Do not imply the user must share a belief system.
- Prefer adaptable instructions.
- Avoid embedding sacred or copyrighted text.

Possible future examples:

- Metta / Loving-Kindness Meditation
- Lectio Divina
- Ignatian Examen
- Mantra Japa
- Mussar-style ethical reflection
- Prayer
- Sacred reading
- Candle or altar reflection

## Selected Practice Shortlists So Far

### Breathwork

Selected:

1. Box Breathing
2. 4-7-8 Breathing
3. Physiological Sigh
4. Alternate Nostril Breathing
5. Extended Exhale Breathing
6. Three-Part Yogic Breath
7. Equal Breathing
8. Counting the Breath
9. One-Minute Breath Reset
10. Sighing Practice
11. Humming Exhale
12. Breath of Fire
13. Wim Hof-Style Breathing
14. Shoulder-Drop Breathing

Notes:

- This category includes calm, sleep, meditative, embodied, micro-reset, expressive release, and high-intensity options.
- Breath of Fire and Wim Hof-style breathing need `high` intensity and clear `avoid_when` values.

### Meditation

Selected:

1. Mindfulness of Breath
2. Open Awareness Meditation
3. Loving-Kindness / Metta Meditation
4. Noting Practice
5. Walking Meditation
6. AHAM Mantra Meditation
7. RAIN Meditation
8. Breath Counting Meditation
9. Do-Nothing Meditation
10. Gratitude Meditation
11. Micro-Meditation Between Tasks
12. Tea Meditation

Notes:

- AHAM was specifically chosen as the mantra for mantra meditation.
- This category includes classical mindfulness, compassion, mantra, emotional processing, daily-life meditation, and micro-practice options.

### Grounding

Selected:

1. 5-4-3-2-1 Grounding
2. Orienting to the Room
3. Feet on the Floor
4. Object Anchor
5. Wall Push
6. Cold Water Face Splash

Notes:

- This set covers sensory inventory, visual orienting, body contact, tactile focus, active pressure, and a stronger temperature reset.

### Movement

Selected:

1. Five-Minute Walk
2. Shaking Practice
3. Gentle Yoga Flow
4. Walking Meditation
5. Dance One Song
6. Qi Gong Flow
7. Somatic Swaying
8. Hip and Jaw Release
9. Child's Pose Rest
10. Body Percussion Tap-Out

Notes:

- This category includes practical, expressive, somatic, contemplative, and lightly playful options.

## Current Open Category: Journaling

We paused while filtering the Journaling candidate list.

Candidate list presented:

1. Morning Pages
2. Gratitude List
3. Thought Download
4. Unsent Letter
5. Needs Check-In
6. Emotion Labeling Journal
7. CBT Thought Record
8. Best Friend Reframe
9. Future Self Letter
10. Values Reflection
11. Three Good Things
12. Worry Window
13. Decision Clarity Page
14. What's True / What's Story
15. Self-Compassion Letter
16. Parts Dialogue
17. Anger Letter
18. Jealousy Inquiry
19. One Sentence Journal
20. Tiny Wins Log
21. Body-to-Page Scan
22. Prompted Freewrite
23. Let It Be Messy Page
24. Apology Draft
25. Boundary Script
26. Dream Journal
27. End-of-Day Reflection
28. Question Storm
29. Permission Slip
30. Two Lists: Holding / Releasing

Next step:

- Filter the Journaling list by selected numbers.
- Then continue generating and filtering long candidate lists for the remaining categories.

Remaining categories after Journaling:

1. Emotional Processing
2. Social Connection
3. Nature
4. Creative Expression
5. Practical Care
6. Sleep & Wind-Down
7. Self-Compassion
8. Values & Intention
9. Spiritual / Contemplative

## Implementation Notes For Later

This planning implies a behavior and schema change.

Expected implementation work:

- Update `Practice` decoding model.
- Replace `description` with `summary`, `steps`, `best_for`, `why_it_helps`, `labels`, `intensity`, and `avoid_when`.
- Update `PracticeLibraryTests`.
- Update any UI currently reading `description`.
- Update Gemini prompt building to use the richer fields.
- Update prompt tests.
- Consider recommendation prompt guidance for category diversity.
- Run `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.

Definition of done for implementation should include:

- Relevant tests updated or added.
- Full test suite passing, or inability to run clearly explained.
- Cleanup pass after implementation.
- Check whether `AGENTS.md` needs updates.

