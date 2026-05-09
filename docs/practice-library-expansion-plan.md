# Practice Library Expansion Plan

Completed planning note for expanding `sift/Resources/practices.yaml` from a small test list into a richer wellness practice library.

This document captures the methodology we agreed on and the selected shortlists that were implemented in `sift/Resources/practices.yaml`.

Status: Complete. The selected category expansion has been implemented in `sift/Resources/practices.yaml`, with bundled library coverage asserted in `siftTests/Models/PracticeLibraryTests.swift`.

## Product Direction

The practice library should become a set of small, executable wellness protocols, not just a list of suggestions.

The app should be able to recommend 3-4 practices after a voice check-in. Users will not browse the full library initially, so the library does not need equal category sizes. Recommendation quality matters more than editorial symmetry.

The library should support experienced users, while staying within a safe middle range. Stronger practices are acceptable when they are well labeled, but practices that imply clinical support, long facilitation, or deep trauma work are out of scope for now.

## Methodology

We are planning in layers:

1. Define high-level, method-based categories.
2. For each category, generate a focused candidate list of up to 20 practices.
3. Filter candidates down manually.
4. Later, enrich each selected practice with structured metadata.
5. Then create an OpenSpec proposal before implementation.
6. During implementation, migrate the model and tests from the old `description`-based schema to the richer schema.

The candidate generation style is:

- Mix canonical practices with warmer, Sift-flavored practices.
- Aim roughly for 3 canonical plus 2 warmer/original practices per category, but do not force the ratio.
- Suggest no more than 20 practices per category during candidate generation; smaller category sizes are fine where fewer strong options exist.
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

### Journaling

Selected:

1. Morning Pages — Three pages of uncensored longhand writing to clear mental clutter.
2. Gratitude List — A short list of specific things the user appreciates right now.
3. Thought Download — A fast, unfiltered dump of everything taking up headspace.
4. Unsent Letter — A private letter to someone that does not need to be sent.
5. Emotion Labeling Journal — Writing down feelings and giving each one a simple name.
6. CBT Thought Record — A structured way to examine a distressing thought and possible alternatives.
7. Best Friend Reframe — Responding to the situation as if advising a beloved friend.
8. Worry Window — Giving worries a contained place and time on the page.
9. What's True / What's Story — Separating observable facts from interpretation or narrative.
10. Anger Letter — A private, bounded letter for expressing anger without acting it out.
11. Jealousy Inquiry — Exploring jealousy as information about longing, fear, or values.
12. One Sentence Journal — Capturing the day or current state in a single sentence.

Notes:

- Selected from candidate numbers 1, 2, 3, 4, 6, 7, 8, 12, 14, 17, 18, and 19.
- This category includes freewriting, gratitude, emotional labeling, cognitive reframing, worry containment, fact/story separation, expressive release, inquiry, and low-effort check-ins.

Remaining categories after Spiritual / Contemplative:

None. Initial category shortlist review is complete.

## Candidate Lists To Review Next

These lists are intentionally capped at 20 practices per category. They are candidate pools, not final selections.

### Emotional Processing

Selected:

1. Name the Feeling — Pause and identify the emotion with simple, precise language.
2. Emotion Wave Surfing — Track a feeling as a wave that rises, shifts, and passes.
3. Somatic Emotion Tracking — Notice where an emotion lives in the body and how it changes.
4. Anger Shake and Settle — Discharge angry energy through shaking, then re-ground.
5. Sadness Hand-on-Heart Sit — Sit with sadness using steady breath and soothing touch.
6. Parts Dialogue — Let different inner parts speak to each other with curiosity.
7. Inner Child Check-In — Ask a younger-feeling part what it needs right now.
8. Letting the Feeling Speak — Write from the emotion's point of view.
9. Shame Softening — Meet shame with privacy, gentleness, and a less punishing story.

Notes:

- Selected from candidate numbers 2, 3, 4, 5, 6, 8, 9, 13, and 15.
- RAIN Practice was not selected here because it already appears under Meditation.

### Social Connection

Selected:

1. Send One Honest Text
2. Appreciation Message
3. Ask for Specific Support
4. Repair Attempt Draft
5. Boundary Script Rehearsal
6. Shared Walk Invitation
7. Micro-Act of Kindness
8. Relationship Gratitude Reflection
9. Reach Out to a Safe Person
10. Offer Practical Help
11. Plan a Low-Pressure Hangout
12. Community Touchpoint

Notes:

- Selected from candidate numbers 1, 2, 3, 4, 5, 7, 8, 10, 11, 13, 14, and 20.

### Nature

Selected:

1. Sit With a Tree — Sit near a tree and notice its shape, texture, and steadiness.
2. Barefoot Ground Contact — Stand barefoot on safe natural ground and notice contact.
3. Birdsong Listening — Listen for birds or outdoor sound without trying to identify everything.
4. Garden Tending — Water, weed, prune, or care for one living thing.
5. Sunrise or Sunset Pause — Pause near sunrise or sunset and let the transition register.
6. Water Listening — Sit near water, rain, or a faucet and listen to its rhythm.
7. Moon Check-In — Notice the moon or night sky as a quiet evening anchor.
8. Fresh Air Reset — Step outside or open a window and take several unforced breaths.
9. Touch Something Living — Gently touch a plant, tree, grass, or soil and notice the sensation.
10. One Block Wonder Walk — Walk one block looking for small details usually missed.

Notes:

- Selected from candidate numbers 2, 3, 5, 6, 8, 10, 13, 14, 16, and 20.

### Creative Expression

Selected:

1. Draw the Feeling — Use lines, shapes, or color to show the current emotional state.
2. One-Song Movement Sketch — Move freely for one song and let the body express the mood.
3. Collage the Mood — Arrange images, scraps, or words that match the current state.
4. Photograph What Matches — Take one photo that reflects the user's mood or attention.
5. Doodle Without Lifting the Pen — Make one continuous-line doodle without judging it.
6. Make a Three-Line Song — Turn the current feeling into a tiny song or chant.
7. Build a Small Arrangement — Arrange objects into a small composition that reflects the moment.
8. Soundtrack the Moment — Choose or make a short soundtrack for the current state.
9. Make a Symbol — Create a simple mark or image for what the user is carrying.
10. Found Object Sculpture — Build a small temporary form from nearby objects.
11. Before-and-After Sketch — Draw how things feel now and how the user wants them to feel.

Notes:

- Selected from candidate numbers 1, 2, 7, 8, 10, 12, 14, 15, 18, 19, and 20.

### Practical Care

Selected:

1. Clear One Surface — Choose one small surface and remove or organize what is on it.
2. Make a Warm Drink — Prepare tea, coffee, or another warm drink with full attention.
3. Change Clothes — Put on clothes that better match the next part of the day.
4. Open a Window — Let in fresh air or light and notice the shift in the room.
5. Put Away Ten Things — Return ten items to their place.
6. Make the Bed — Reset the bed as a small environmental anchor.
7. Delete or Snooze One Task — Remove, defer, or clarify one nagging task.
8. Do the Next Small Step — Identify and complete the smallest possible next action.
9. Clean Your Glasses or Screen — Clean one object the user looks through or at often.
10. Make a Tiny Plan — Write a short plan for the next hour or next part of the day.

Notes:

- Selected from candidate numbers 1, 2, 4, 7, 9, 10, 11, 13, 19, and 17.

### Sleep & Wind-Down

Selected:

1. Body Scan in Bed — Move attention through the body while lying down.
2. Legs Up the Wall — Rest with legs elevated to settle the body.
3. Evening Brain Dump — Write down loose thoughts so they do not have to be held mentally.
4. Tomorrow List — Make a short list of tomorrow's key tasks or reminders.
5. Gentle Stretch Sequence — Do a few soft stretches to release the day.
6. Low-Light Room Reset — Dim lights and adjust the room for sleep.
7. Gratitude Three — Name three good things from the day.
8. Yoga Nidra Short Form — Follow a brief lying-down guided rest sequence.
9. Screen-Off Transition — Put screens away and do one quieter replacement activity.
10. Bedtime Prayer or Blessing — Offer a short prayer, blessing, or closing phrase.
11. Sound Bath Listening — Listen to calming ambient sound or music with full attention.
12. Closing the Day Reflection — Briefly acknowledge what happened and let the day end.

Notes:

- Selected from candidate numbers 2, 3, 4, 5, 6, 8, 9, 11, 13, 16, 19, and 20.

### Self-Compassion

Selected:

1. Hand-on-Heart Practice — Use a gentle hand placement as a cue for warmth and steadiness.
2. Permission Slip — Write a short note granting permission to rest, feel, ask, or begin.
3. Kind Inner Voice Rewrite — Rewrite harsh self-talk in a firm but kinder voice.
4. Name What Was Hard — Acknowledge the real difficulty without minimizing it.
5. Mistake Repair Without Punishment — Identify one repair step without self-attack.
6. Self-Forgiveness Sentence — Write one sentence of forgiveness or willingness to soften.
7. Let Yourself Be a Beginner — Practice allowing awkwardness or imperfection while learning.

Notes:

- Selected from candidate numbers 3, 4, 8, 9, 12, 14, and 17.

### Values & Intention

Selected:

1. Values Card Sort — Choose from a set of values and notice which feel most alive today.
2. One-Word Intention — Pick one word to orient the next hour, day, or situation.
3. Future Self Check-In — Ask what a wiser future self would want remembered now.
4. Energy Audit — Notice what gives, drains, or deserves energy.
5. What Matters Today — Name what deserves attention today and what can wait.
6. Anti-Goal Clarifier — Define what the user does not want to optimize for.
7. Yes / No Inventory — List what deserves a clearer yes or no.

Notes:

- Selected from candidate numbers 1, 2, 4, 8, 11, 12, and 17.

### Spiritual / Contemplative

Selected:

1. Metta / Loving-Kindness Meditation — Offer phrases of goodwill to self, others, and wider life.
2. Lectio Divina — Read a short sacred or meaningful passage slowly and listen for resonance.
3. Mantra Japa — Repeat a chosen mantra with breath, beads, or steady attention.
4. Silent Prayer — Sit quietly in prayerful presence without needing many words.
5. Sacred Reading — Spend a few minutes with a sacred, philosophical, or wisdom text.
6. Loving Presence Sit — Rest in the sense of being held by compassion, God, life, or awareness.
7. Altar or Object Reflection — Sit with a meaningful object and reflect on what it represents.
8. Interdependence Reflection — Contemplate the web of people, beings, and conditions supporting life.
9. Mussar-Style Ethical Reflection — Reflect on one character trait and how it is showing up.

Notes:

- Selected from candidate numbers 1, 2, 4, 5, 7, 10, 11, 17, and 13.

## Implementation Status

Complete:

- Selected practices are implemented in `sift/Resources/practices.yaml`.
- Bundled library coverage is asserted in `siftTests/Models/PracticeLibraryTests.swift`.
- `xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` passed after implementation.
- `AGENTS.md` was checked and did not need updates.
