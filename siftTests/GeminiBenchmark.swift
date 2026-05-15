// To enable: set GEMINI_API_KEY in the scheme's environment (Edit Scheme → Test → Arguments → Environment Variables).
// Each iteration consumes Gemini API credits. Run with `xcodebuild test` against the iPhone 17 Pro simulator
// with the env var present, or via the Test navigator in Xcode.
//
// Output lines prefixed with "BENCHMARK" are emitted to standard output, parseable by tooling.

import Foundation
import Testing
@testable import sift

@MainActor
struct GeminiBenchmark {
    static let fixtureTranscripts: [String] = [
        "I've been feeling overwhelmed at work lately. The deadlines keep piling up and I can't seem to catch a breath. Even when I try to relax in the evening, my mind keeps spinning.",
        "Today was actually pretty good. I had a nice walk this morning and felt grounded. Just want to keep this feeling going through the afternoon.",
        "I'm angry. My coworker took credit for my work in the meeting and I didn't say anything. Now I'm replaying it over and over and can't focus on anything else.",
        "I feel disconnected from my body. Been at the desk all day and I'm kind of numb. I know I should move but I just don't have the energy to start.",
        "Anxious about a conversation I need to have tomorrow with my partner about money. Don't even know where to start and the avoidance is making it worse.",
    ]

    @Test(
        .disabled(if: ProcessInfo.processInfo.environment["GEMINI_API_KEY"] == nil,
                  "Set GEMINI_API_KEY in scheme env to run benchmark"),
        arguments: 1...10
    )
    func benchmarkGeminiRecommend(iteration: Int) async throws {
        let apiKey = try #require(ProcessInfo.processInfo.environment["GEMINI_API_KEY"])

        let transcript = Self.fixtureTranscripts[(iteration - 1) % Self.fixtureTranscripts.count]

        // Pass recorder: nil so benchmark events do NOT persist to the debug-screen store.
        let service = GeminiService(
            router: GeminiRecommendationRouter(requester: LiveGeminiModelRequester(), recorder: nil),
            apiKeyProvider: { apiKey },
            logger: { _ in },
            recorder: nil
        )

        let start = Date()
        let result = try await service.recommend(transcript: transcript, history: [])
        let ms = Int(Date().timeIntervalSince(start) * 1000)

        let confidence = String(format: "%.2f", result.confidence)
        print("BENCHMARK iter=\(iteration) ms=\(ms) model=\(result.modelUsed) conf=\(confidence) escalated=\(result.wasEscalated)")
    }
}
