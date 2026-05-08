# Sift

iOS wellness companion app built with SwiftUI, SwiftData, WhisperKit, and Gemini.

## First-run setup

Open `sift.xcodeproj` in Xcode 26.4.1 or newer.

The app builds without a Gemini API key. Without a key, the first Gemini recommendation request fails with the in-app missing-key error instead of making a network request.

To enable real Gemini recommendations locally:

1. Copy `sift/Services/GeminiAPIKey.local.example` to `sift/Services/GeminiAPIKey.local`.
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your Gemini API key.
3. Build and run the app. Xcode copies the ignored local key into the app bundle for both simulator and device builds.
4. Keep `sift/Services/GeminiAPIKey.local` uncommitted.

`sift/Services/Secrets.swift` is a checked-in safe fallback that reads the bundled local key at runtime. Do not put real keys in it.

## Build and test

```sh
xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild test -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
