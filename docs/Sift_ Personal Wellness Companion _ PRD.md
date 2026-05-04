# Sift: Personal Wellness Companion — PRD

### TL;DR

Sift is a voice-first iOS wellness companion that helps 'aware but overwhelmed' users cut through the noise of wellness advice to discover the 3–4 personal practices that actually work for them. Powered by conversational AI with memory, Apple Health/Watch integration, and a dynamic “cheat sheet,” Sift helps users feel better—then steps out of the way until it’s needed again.

---

## Goals

### Business Goals

* Launch a meaningful and low-cost wellness tool as a passion project, not a venture-backed scale app.
* Achieve high user satisfaction and trust, as measured by positive App Store reviews and word-of-mouth.
* Operate with minimal ongoing cost—single or low-cost annual payment model, no push for rapid monetization.
* Prioritize privacy and user well-being over engagement or data extraction.

### User Goals

* Discover and retain the few personal wellness practices that genuinely help them feel better.
* Build a personal protocol—3–4 stable practices tailored to their rhythms and preferences.
* Feel genuinely supported and less alone during periods of life difficulty or stress.
* Seamlessly return to their best practices after falling off track, without guilt or friction.
* Avoid overwhelming content, prescriptive programs, or gamification pressure.

### Non-Goals

* Sift will **not** be a content library or guided meditation archive (e.g., Calm, Headspace).
* Sift will **not** employ habit-streak or gamification mechanics to drive daily engagement.
* Sift is **not** designed for wellness beginners unfamiliar with basic practices or self-tracking (i.e., users need some prior context).

---

## User Stories

### Persona 1: The Returning User

* As a returning user, I want to check in after a hard stretch, so that I can quickly be reminded of the practices that helped me before.
* As a returning user, I want the app to remember my previous wins, so that I feel seen and not like I’m starting from scratch.
* As a returning user, I want to build on my prior reflections and protocols, so that I can rebuild my well-being without sifting through advice again.

### Persona 2: The Overwhelmed Explorer

* As an explorer, I want to check in on a rough day using voice, so that I don’t have to type or fill out forms when I’m low on motivation.
* As an explorer, I want to use the cheat sheet when I’m too tired to talk, so that I can try something that’s likely to work with minimal energy.
* As an explorer, I want to reflect on whether a practice actually helped me, so that I can filter out what doesn’t work.
* As an explorer, I want to see insights about my patterns, so that I can understand how my feelings, behavior, and health data interact.
* As an explorer, I want the app to recognize when I come back after months away, so that my progress and preferences are remembered.

---

## Functional Requirements

* **Check In Mode** (Priority: Highest)

  * Voice-first AI conversational flow (optionally text input).
  * Mood and context capture via natural language and selectable tags.
  * Back-and-forth chat with memory of user’s context, practices, and recent days.
  * AI-generated concise summary of current well-being and insight surfacing.

* **Just Show Me Mode** (Priority: Highest)

  * Static, personalized “cheat sheet” of 3–4 suggested practices.
  * One-tap logging/completion for each practice with minimal UI friction.
  * Option to quickly reflect “Did this help?” with quick feedback scale.

* **Practice Management** (Priority: Medium)

  * Practice library with vetting for evidence-based and user-supplied options.
  * Minimum trial threshold—require 3–5 attempts before allowing users to retire/skip a practice.
  * Resistance scoring—capture perceived “friction” or “effort” for each suggestion.
  * Intelligent rotation—app cycles in new practices if one is consistently avoided.
  * Explicit “does not work for me” to permanently remove a practice.

* **Apple Ecosystem Integration** (Priority: High)

  * Read-only integration with HealthKit (HRV, sleep, heart rate, activity).
  * Optional Apple Watch integration for richer data and passive input.
  * Secure syncing and permissions management (privacy-forward by default).

* **AI Memory & Longitudinal Intelligence** (Priority: Medium)

  * Persist user’s history of practices, mood, and context.
  * Detect and surface seasonal trends or recurring patterns.
  * Surface “prior wins” and supportive narrative on user return after absence.

* **Weekly Narrative Summary** (Priority: Medium)

  * Compose a single-paragraph, human-readable summary of the user’s week.
  * Emphasize qualitative reflection, not charts or graphs.

---

## User Experience

**Entry Point & First-Time User Experience**

* Users discover Sift in the App Store—messaging emphasizes “find what works for you” and intelligent, non-preachy support.
* First launch opens directly into a conversational onboarding led by calm voice or text (user chooses). No forms, minimal taps.
* The AI gently asks about existing practices, personal goals, and recent experiences.
* Sift learns about the user’s context and imports existing HealthKit data with permission.

**Core Experience**

* **Step 1:** User opens the app and chooses between “Check In” and “Just Show Me.”

  * Home screen has clear, minimal buttons for both paths.
  * App remembers user’s last-used mode and subtly recommends the most helpful mode (learned over time).

* **Step 2a: Check In Mode**

  * User records a voice message or types about how they’re feeling and what’s on their mind.
  * Conversational AI analyzes their mood, detects context, and asks follow-up questions if needed (e.g., “Would you like to try something that’s helped before?” or “How did yesterday’s breathwork go?”).
  * AI summarizes: “It sounds like you’re feeling X. Last month, breathwork and journaling were helpful for you. Here are three things to consider today.”
  * Recommendations are surfaced along with reasoning (“This helped when you felt this way last time.”).
  * User can accept, decline, or mark resistance to suggestions.

* **Step 2b: Just Show Me Mode**

  * The app instantly displays a cheat sheet: 3–4 practices, selected based on what’s worked in the past and current context.
  * User can tap to mark a practice as done. Optionally, a quick single-tap or swipe to reflect on its helpfulness.
  * Minimal cognitive overhead—no journaling, no narrative unless user wants.

* **Step 3:** Practice reflection (optional)

  * After trying a practice, the user can add a short voice or text reflection, rate helpfulness, or add “resistance” feedback.
  * AI prompts the user to try each practice a minimum of 3–5 times before retiring.

* **Step 4:** Weekly and return flow

  * On a weekly cadence (user configurable), Sift generates a narrative summary of their progress and “what seems to work for you,” delivered in prose.
  * When a user returns after a long break, Sift welcomes them back, summarizes prior successful practices, and gently gets them back on track.

**Advanced Features & Edge Cases**

* For a returning user after months away, the app surfaces their last successful protocols and asks if they want to pick up where they left off.
* When a user tries to retire a practice before the minimum trial count, app explains the threshold (“Consistency matters—let’s try it a bit more before we decide”).
* If high resistance is logged repeatedly, AI distinguishes between “not for me” vs “not right now” and rotates in a new suggestion if appropriate.
* All interaction modes (voice/text) are equally accessible—user can change at any time.
* Privacy notices are prominent whenever the mic is active.

**UI/UX Highlights**

* Calm, grounded, and non-gamified visual style (e.g., soft neutrals, non-intrusive animations, intentional whitespace).
* Warm, supportive, and intelligent copy—never preachy or condescending.
* No streaks, trophies, or guilt-based messaging.
* Accessible font sizes, high color contrast, voiceover accessible.
* Voice data processed on-device where possible; user can always choose text-only.

---

## Narrative

Alex, a mid-30s professional, has weathered a few stressful months. Once, breathwork and journaling were a natural part of their days, but deadlines and life’s chaos pushed those supporting rituals aside. Now, when things feel heavy again, Alex opens Sift.

Sift greets Alex by name and listens as they share how they're feeling—no forms, no pressure, just a warm AI presence. Sift remembers Alex’s past wins: breathwork, short walks, body scans. It gently presents a cheat sheet, tailored to exactly where Alex is today. Alex gives breathwork another try. The next day, there’s a little more lightness. Over the following weeks, Sift helps Alex retest and refine their core practices—not by dictating a new regime, but by learning what Alex’s own “better” looks like over time.

When life improves, Alex naturally puts Sift aside—no nags, no guilt. But when the need arises again, Sift is there, reminding Alex of what truly works. For Alex, it’s not just another wellness app. It’s a personal compass in the storm.

---

## Success Metrics

* **% of users who identify a personal practice protocol (3–4 stable practices) within 90 days.**
* **Return rate after 3+ months of inactivity** (the “comeback” metric).
* **Reflection completion rate** after practices are logged.
* **Low churn relative to usage cycles** (factoring in natural dormancy periods).
* **App Store rating average** (target ≥ 4.5 at launch).
* **Word-of-mouth referral rate** (measured through referral codes/links).
* **Voice recognition accuracy** (measured by transcription success without error).
* **HealthKit data sync reliability** (incidence of sync errors or missed data).
* **AI response latency** (<2 seconds average in-app response).

### Tracking Plan

* Check-in initiated (voice vs. text)
* Practice logged/completed (per practice)
* User reflection submitted after practice
* Cheat sheet viewed (vs. conversation initiated)
* Practice retired (and reason if supplied)
* App reopened after 30+ day gap
* Narrative summary read/opened

---

## Technical Considerations

### Technical Needs

* On-device speech-to-text using Apple Speech framework for privacy and responsiveness.
* AI conversational layer with user-specific persistent memory (local or iCloud-sync’d data).
* HealthKit integration to passively pull HRV, sleep, heart rate, and step/activity data.
* Front-end: native Swift/iOS UI, voice and text input UI, personalized cheat sheet display.
* CoreML for basic on-device pattern recognition (trends, basic clustering).

### Integration Points

* Apple HealthKit (iOS)
* Apple Watch (optional input, deep link to Watch app)
* Apple Speech API (voice processing)
* Lightweight on-device LLM (CoreML) or optionally privacy-focused cloud fallback

### Data Storage & Privacy

* All personal data stored on-device or in user’s private iCloud.
* No central health data server or external analytics.
* On-device data encrypted at rest; iCloud backup for persistence across devices and reinstalls.
* Voice data processed on-device; user can opt out entirely.

### Scalability & Performance

* MVP is a single-user, personal app—no backend social architecture.
* Should perform smoothly with up to several years’ history per user.
* AI conversations and cheat sheet generation must render in <2 seconds.

### Potential Challenges

* Ensuring voice privacy and user trust (transparent permission prompts, no background mic use).
* AI memory architecture must degrade gracefully if history is sparse.
* Avoiding over-correlation of biometrics (e.g., HRV) with mood/subjective data, respecting data complexity.
* Handling Apple API changes/permissions edge cases (esp. HealthKit/watchOS updates).

---

## Milestones & Sequencing

### Project Estimate

* **Medium Project** (6–10 weeks total, including polish and App Store readiness)

### Team Size & Composition

* **Lean Team** (2–3 people):
  * 1 Product/Design (Jeremy)
  * 1–2 iOS engineers (full/part-time)
  * 1 AI/ML engineer (fractional or consultant, as needed)

### Suggested Phases

**Phase 1: Core Flow MVP (2–3 weeks)**

* Deliverables:
  * Basic conversational check-in flow (text only)
  * Static practice library and cheat sheet display
  * Manual practice logging and feedback
* Dependencies:
  * N/A (standalone MVP)

**Phase 2: Voice & HealthKit Integration (2–3 weeks)**

* Deliverables:
  * Voice input and output (transcription, on-device where possible)
  * HealthKit sync for HRV, sleep, heart rate, and activity data
  * AI memory: initial longitudinal storage and recall
* Dependencies:
  * Apple Speech and HealthKit certifications/permissions

**Phase 3: Practice Intelligence & Narrative (2 weeks)**

* Deliverables:
  * Resistance scoring, minimum trial threshold enforcement, practice rotation logic
  * Weekly AI-generated narrative summary
* Dependencies:
  * Completion of practice management logic

**Phase 4: Polish & Launch Prep (1–2 weeks)**

* Deliverables:
  * Refined onboarding, visual polish, accessibility improvements
  * App Store prep: screenshots, description, privacy policy
  * Final QA, bug-fixing
* Dependencies:
  * All previous phases complete

---

**Sift** is designed to be a quiet, supportive companion—something you can trust to help you find what works, and leave you alone when you no longer need it.