# Handoff: Sift iPhone Design System & Screens

## Overview
Visual design for **Sift**, a quiet voice-first wellness companion for iOS. Covers
the eight core screens (Home, Recording, Analyzing, Suggestions, Practice Detail,
Reflection, History, Privacy) plus their important edge states, all locked to the
**Midnight** palette. A complete tokens/components reference is included.

## About the Design Files
The files in `prototype/` are **design references created in HTML/JSX** — visual
prototypes showing intended look, spacing, and behavior, **not production code to
copy directly**. The task is to **recreate these designs in the existing SwiftUI
codebase** at `/Users/jeremy/code/sift/sift`, using its established patterns
(views like `RecordingScreen`, `SuggestionView`, etc.) and SwiftUI primitives.

Open `prototype/index.html` in a browser to see all screens side-by-side on a
zoomable canvas. Each iPhone frame is 320 × 680 design pts; targeting iPhone 15/16
(393 × 852 logical pts), so **scale spacing/type values up by ~1.23×** when porting
(e.g. a 22 pt gutter becomes ~27 pt, a 14 pt body becomes ~17 pt). Or use the values
verbatim — they're already comfortable.

## Fidelity
**High-fidelity.** Final colors, type, spacing, and component shapes are decided.
Recreate pixel-equivalent in SwiftUI. The *prototype* lives in HTML for fast iteration;
the *design intent* — tokens, hierarchy, copy, shapes — is final.

---

## Design Tokens — Midnight (canonical)

```swift
// SiftTokens.swift
import SwiftUI

enum SiftColor {
    static let bg          = Color(hex: 0xDDE0EB)   // app background
    static let surface     = Color(hex: 0xECEDF3)   // cards, tab bar
    static let surfaceAlt  = Color(hex: 0xC8CCDD)   // sunken / icon tiles
    static let ink         = Color(hex: 0x0E1430)   // primary text
    static let muted       = Color(hex: 0x4A527A)   // body / secondary
    static let quiet       = Color(hex: 0x8A90B0)   // tertiary, eyebrows
    static let line        = Color(hex: 0x0E1430).opacity(0.10)
    static let accent      = Color(hex: 0x3A4AB0)   // primary action
    static let accentSoft  = Color(hex: 0xBCC4EC)   // soft fill
    static let accentInk   = Color(hex: 0x1A2270)   // accent on light
    static let helpful     = Color(hex: 0x5A7A9A)   // "helped before"
    static let danger      = Color(hex: 0xA85674)
    static let tabIcon     = Color(hex: 0x7A82A4)
}

enum SiftRadius {
    static let card: CGFloat   = 18
    static let pill: CGFloat   = 999
    static let button: CGFloat = 18
    static let tile: CGFloat   = 14   // icon backdrop tiles
}

enum SiftSpace {
    static let gutter: CGFloat   = 22
    static let cardPad: CGFloat  = 16
    static let rowGap: CGFloat   = 10
    static let sectGap: CGFloat  = 28
}
```

### Typography — Figtree (humanist sans, weights 400/500/600)
Use the `Figtree` family from Google Fonts (or substitute SF Pro Rounded if Figtree
isn't available — visually close enough). Leading 1.2–1.55 depending on size.

| Role     | Size | Weight | Tracking | Notes |
|----------|------|--------|----------|-------|
| Display  | 30   | 600    | -0.6     | Screen titles ("History") |
| Title    | 22   | 600    | -0.4     | Section headers ("How did that land?") |
| Heading  | 17   | 600    | -0.3     | Card headings, "Try one of these" |
| Body     | 14   | 400    |  0       | Paragraphs, descriptions |
| Caption  | 12   | 500    |  0.2     | Time stamps |
| Eyebrow  | 11   | 600    |  1.2 (uppercase) | "WHAT I REMEMBER" |
| Pill     | 10.5 | 500    |  0.2     | Tags |

### Shadows
Soft, low-y, low-opacity. One canonical card shadow:
`shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)`
Primary button: `shadow(color: accent.opacity(0.18), radius: 16, x: 0, y: 6)`

### Motion
- Tap: `.spring(response: 0.3, dampingFraction: 0.8)`
- Screen transitions: 0.35 s ease-in-out
- Waveform/breathing dot: 4–6 s sine loop, infinite

---

## Screens

Each screen has a canonical state and (where shown) edge states. Coordinates are
relative to the 320 × 680 design frame. All layouts are vertical stacks with
`SiftSpace.gutter` (22) horizontal padding unless noted.

### 1. Home / Today
**Purpose** Calm landing. One big intent: tap to record.
**Layout, top → bottom** (status bar excluded; padTop ≈ 60)
- Eyebrow line ("FRIDAY · 2:14 PM" or "WELCOME TO SIFT" first run), 11/600 quiet, uppercase.
- Display H1 with two-tone treatment: ink line then muted continuation
  (e.g. "Hi.\nTake a moment to arrive."). 30/600, line-height 1.18, balanced wrap.
- Body paragraph(s), 14/400 muted, line-height 1.55. Up to ~3 lines.
- Spacer (flex).
- **Tap-to-begin button**: 132 × 132 outer radial-gradient (accentSoft → bg)
  with an inner 78 × 78 accent-filled circle, mic glyph in white. 14/500 muted
  caption "Tap to begin" below.
- *(First run only)* Three dashed pills with starter prompts:
  "Right now I notice…" · "What feels hard…" · "What I need…"
- TabBar pinned bottom.

**Edge state — First run (empty)** as above with starter prompts visible.

### 2. Recording
**Purpose** Listen and transcribe on device. No red mic, no level bars.
- Eyebrow "LISTENING". Display "I'm here." line ink, "Take your time." muted.
- Centered **WaveformRibbon** (3 stacked sine layers, accent color, animated 5–6 s)
  in a centered band ~80 pt tall.
- Live transcript fragment as italic body, faded (`muted`), wrapped to 2 lines.
- Bottom: a soft **Stop** pill (accentSoft fill, accentInk text) and a tiny
  "Reading on this phone only." privacy footnote in 11/500 quiet.

**Edge — Model loading (first run):** centered concentric "breathing dot"
(3 thin accent rings + filled center), title "Getting Sift ready", body
explaining on-device prep, progress bar (4 pt tall, accent fill on surfaceAlt
track) + monospace "62% · 38 MB / 62 MB".

**Edge — Mic denied:** centered icon (mic glyph crossed by danger stroke)
in a surface circle, title "Mic access is off", body, primary "Open Settings",
ghost "Type instead".

### 3. Analyzing
**Purpose** Brief pause while LLM reflects + suggests.
- Centered **breathing dot**: 3 concentric thin accent rings + small accent dot.
- Title "Reading what you shared", muted body "A moment of quiet while I take it in."

**Edge — Network error:** the same icon-circle pattern, title "Sift can't reach
the network", reassurance about local transcript safety, then a **Saved
transcript** card (surface, italic ink quote), then primary "Try again" + ghost
"Show me what helped before".

### 4. Suggestions
**Purpose** 2–3 practices, with optional memory recall.
Top → bottom:
- Eyebrow "YOU SHARED", italic body quote of user's transcript.
- *(Returning users)* **"What I remember"** insert: a 2 pt left border in
  `accent`, surface fill rounded only on the right (`0 14 14 0`),
  accentInk eyebrow "WHAT I REMEMBER", ink body referencing past patterns.
- Section header row: "Try one of these" (Heading 17/600) + "3 suggestions"
  caption right-aligned.
- **Practice cards** (one per practice, 10 pt row gap):
  - 14 pt padding, surface bg, line border, card radius.
  - Left: 42 × 42 surfaceAlt tile (radius 12), `CategoryIcon` (24 pt) in accentInk.
  - Right column: name (15/600 ink) + duration "~3 min" right-aligned (11/quiet),
    summary (12.5/400 muted, 1.5 line-height), then a row of pills:
    `<PillTag soft>{Category}</PillTag>` + `<PillTag helpful>✓ Helped before</PillTag>`
    + optional italic caption "last tried 12 days ago" (10.5/quiet).
- Footer: ghost button "Done · maybe later".

### 5. Practice Detail (e.g. Box Breathing)
**Purpose** Walk through the steps of a single practice.
- Back chevron + small eyebrow "BREATHWORK · ~3 MIN".
- Display title "Box Breathing", muted intro paragraph (the practice `summary`).
- **Steps card** (surface, line border, card radius, 16 pt pad):
  - Each step is a row: small numbered chip (24 pt circle, surfaceAlt bg, accentInk
    digit) + step body (14/400 ink, 1.5 leading), 12 pt vertical gap between steps.
- "Why it helps" expander with eyebrow + muted italic body.
- Sticky bottom: primary button "Begin" + ghost "Save for later".

### 6. Reflection
**Purpose** "Did that help?" — a single quiet capture.
- Eyebrow "AFTER".
- Title "How did that land?" (22/600 ink).
- Three radio rows in a surface card: "Helped" / "A little" / "Not really" —
  each is a row with a 20 pt circle on the left (filled accent when selected, line
  ring otherwise) and ink label, 14 pt vertical pad, separated by line dividers.
- Optional note field: borderless multiline text on surface, placeholder
  "(optional) anything else you want to mark…" in 13/quiet.
- Bottom: primary "Save reflection", ghost "Skip for now".

### 7. History
**Purpose** Quiet record of check-ins; what helped.
- Display "History" + caption ("17 check-ins over the last 6 weeks." / "A quiet record…").
- *(Returning)* **"What seems to work"** insight card (surface): eyebrow + italic
  ink prose summarizing patterns.
- Grouped sections: each group has a quiet eyebrow ("This week" / "Last week" /
  "Earlier"), then a single rounded surface card with stacked rows (line dividers):
  - Row: 36 pt left column with day abbreviation (13/600 ink) + time/date (10/quiet),
    flex middle column with italic mood quote (13/ink) and a pill row
    (PillTag soft for practice + colored "· Helped" / "· A little" / "· —" caption
    using `helpful` / `muted` / `quiet`).

**Edge — Empty:** dashed surface card with a small lines glyph in a 56 pt circle,
"Nothing here yet" heading, body, full-width primary "Start a check-in".

### 8. Privacy
**Purpose** Plain-language reassurance.
- Title "Your voice stays here." (or similar).
- Three feature rows, each with a category-style icon tile + heading + body:
  on-device transcription, no third-party transcripts, opt-in cloud reflection.
- Tiny print footnote linking to the full policy.
- TabBar.

---

## Components

### `Phone` (only for the prototype canvas)
Used to frame screens for review. **Don't port this** — the real app runs in
the device.

### `StatusBar`
Top 54 pt bar with "9:41" left, signal/battery glyphs right. Tint = `ink`.
SwiftUI: leave to system.

### `TabBar`
Custom soft tab bar, **not the system one**. Pinned 26 pt up from bottom, 12 pt
side insets. Surface bg, line border, radius 24, soft shadow.
- Three items: **Today** (target/concentric dot), **History** (3 stacked lines),
  **Privacy** (shield outline). 22 × 22 stroke icons.
- Active item: surfaceAlt pill behind icon, label in `accent`, label weight 600.
- Inactive: icon in `tabIcon`, label 500.
- Label 10.5 pt, 3 pt above icon, letter-spacing 0.1.

### `WaveformRibbon`
Three stacked sine paths over a 280 × 110 band, all in `accent`, opacities
0.95 / 0.55 / 0.30 and stroke widths 2.2 / 1.8 / 1.4.
Each path is 60 segments, amplitude 22/16/11 px, edge-tapered (factor
`1 − |i/N·2−1|·0.6`). Phase per layer 0 / 1.6 / 3.1 rad. Animate by interpolating
between four phase-shifted variants over 5–7 s, repeating. Round caps.
SwiftUI: a `TimelineView(.animation)` driving a `Path` for each layer.

### `CategoryIcon` — 14 categories
Hand-style strokes, 1.4 px stroke, round caps, 28 × 28 viewBox, accentInk fill.
The 14 keys (must match `practices.yaml`):

```
Breathwork              · concentric circles + center dot
Meditation              · seated figure (head circle, folded body, base line)
Grounding               · sprout with two leaves + earth line + small roots
Movement                · striding figure (head, torso line, two leg paths)
Journaling              · open book outline + pen mark
Emotional Processing    · heart with a soft inner ripple
Social Connection       · two figures with hands meeting
Nature                  · single leaf with midrib
Creative Expression     · brushstroke arc + sparks
Practical Care          · mug with steam + handle
Sleep & Wind-Down       · crescent moon with small glints
Self-Compassion         · heart cradled by an open hand
Values & Intention      · compass diamond inside a circle
Spiritual / Contemplative · single candle flame on a base
```

Exact path data is in `prototype/shared.jsx` → `CategoryIcon`. Port to SwiftUI as
a `Shape` per category (or one `Canvas`/`Path` switch). Keep them as pure stroke
icons — never filled — and inherit color from the parent (`.foregroundStyle(...)`).

### Buttons
- **PrimaryButton** — full-width, 14 × 22 pad, radius 18, `accent` bg, white text
  15/600. Inner highlight `0 1 0 rgba(255,255,255,0.2) inset` + soft accent glow.
- **PrimaryButton (soft)** — same shape, `accentSoft` bg, `accentInk` text, no shadow.
- **GhostButton** — full-width, 12 × 22 pad, radius 18, transparent bg, line border,
  ink text 14/500.

### `PillTag`
Inline-flex, 3 × 9 pad, radius 999, 10.5/500 with 0.2 letter-spacing, 0.5 px border.
Tones:
- **default**: transparent bg, muted text, line border.
- **soft**: surfaceAlt bg, muted text, transparent border.
- **helpful**: transparent bg, helpful text + helpful border (used for "✓ Helped before").

---

## Interactions & Behavior
- Home → Recording: tap circle. Begin AVAudioRecorder; show waveform; transcribe on device (Speech framework).
- Recording → Analyzing: tap Stop. Pass transcript to LLM; show breathing dot; on success → Suggestions, on network error → Network error edge state.
- Suggestions card tap → Practice Detail.
- Practice Detail "Begin" → in-practice timer/breath visual (not designed yet, OK to defer).
- Practice end → Reflection.
- Reflection "Save" → Home with quiet toast.
- History row tap → session detail (not designed yet).
- All transitions: 0.35 s ease-in-out, fade + 8 pt slide-up.

## State & Data
- `transcript: String` — locally produced, never leaves device unless user opts in.
- `suggestions: [Practice]` — fetched once per check-in.
- `recentReflections: [Reflection]` — local storage; powers "Helped before" + History.
- `practices.yaml` — bundle resource, parsed at launch into `[Practice]` keyed by `id` and `category`.

## Files
Open `prototype/index.html` in a browser. Sub-files:
- `shared.jsx` — `PALETTES`, `CategoryIcon` (all 14 paths), `WaveformRibbon`,
  `TabBar`, `Phone`, `StatusBar`, `PillTag`, `PrimaryButton`, `GhostButton`.
- `screens-1.jsx`, `screens-2.jsx` — canonical screens.
- `screens-3.jsx` — design-system reference board + edge states.
- `index.html` — wires it all up on a pan/zoom canvas.

The other two palettes shown in `PALETTES` (Apricot, Honey, etc.) are *not* canonical
— Midnight is the locked direction. They exist so design can A/B if needed later.
