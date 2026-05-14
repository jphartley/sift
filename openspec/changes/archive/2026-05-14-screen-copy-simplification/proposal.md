## Why

The app's screens contain redundant labels, overly long copy, and misleading UI elements that create visual noise and undermine the calm, minimal tone Sift aims for. These are small polish changes that can be addressed together in one pass.

## What Changes

- **Loading screen**: Remove the subtitle that duplicates the title and footer
- **Today/Check-in screen**: Remove the timestamp label (date/time already shown in iOS status bar); shorten the instruction text; replace dashed-border prompt hints with a plain "For example:" list
- **Recording screen**: Remove the "LISTENING" status label, "I'm here." line, and "Reading on this phone only." privacy note; keep only "Take your time." with the waveform and Stop button
- **Analyzing screen**: Remove the "A moment of quiet while I take it in." subtitle
- **Results screen**: Remove the "What I Remember" section (duplicates "Why these might fit"); make "You Shared" visually secondary and "Why these might fit" visually dominant; replace the "Done · maybe later" button with "I'm good for now" styled as clearly active
- **After/Reflection screen**: Remove the "AFTER" label; update placeholder text to "(Optional) anything else you want to share..."

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `voice-check-in`: UI copy and visual hierarchy changes across the check-in flow screens

## Impact

- SwiftUI view files for: loading screen, today screen, recording screen, analyzing screen, results screen, reflection screen
- No logic, data model, or API changes
