// Run via scripts/run-benchmark.sh. Reads the API key from sift/Services/GeminiAPIKey.local
// (the same gitignored file the app uses — no extra setup needed).
// Skips automatically if the file is absent or empty.
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
        .disabled(if: Secrets.geminiApiKey.isEmpty,
                  "Add API key to sift/Services/GeminiAPIKey.local to run benchmark"),
        arguments: 1...20
    )
    func benchmarkGeminiRecommend(iteration: Int) async throws {
        let apiKey = Secrets.geminiApiKey
        let experiments = AnalysisLatencyExperimentStore()

        let transcript = Self.fixtureTranscripts[(iteration - 1) % Self.fixtureTranscripts.count]

        // Pass recorder: nil so benchmark events do NOT persist to the debug-screen store.
        let service = GeminiService(
            router: GeminiRecommendationRouter(requester: LiveGeminiModelRequester(), recorder: nil),
            apiKeyProvider: { apiKey },
            logger: { _ in },
            recorder: nil,
            experimentStore: experiments
        )

        let start = Date()
        let result = try await service.recommend(transcript: transcript, history: [])
        let ms = Int(Date().timeIntervalSince(start) * 1000)

        let confidence = String(format: "%.2f", result.confidence)
        let labels = experiments.activeLabels.isEmpty ? "baseline" : experiments.activeLabels.joined(separator: "|")
        print("BENCHMARK iter=\(iteration) ms=\(ms) model=\(result.modelUsed) conf=\(confidence) escalated=\(result.wasEscalated) experiments=\(labels)")
    }
}
