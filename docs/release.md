# Release Notes

## App Store builds

- The Debug panel is compile-time gated behind `#if DEBUG` in `ContentView.swift` and `SiftTabBar.swift`.
- App Store submissions should be archived from the Release configuration, not Debug.
- If the Debug tab appears in a build intended for TestFlight or the App Store, check the active build configuration first. Release builds should not define `DEBUG`.

## What to verify before shipping

- Archive with the Release configuration.
- Confirm the app launches into the normal Today/History/Privacy flow.
- Confirm the Debug tab is absent from the tab bar in the shipped build.
