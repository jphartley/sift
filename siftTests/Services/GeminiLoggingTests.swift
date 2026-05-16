import Foundation
import Testing
@testable import sift

struct GeminiLoggingTests {

    // MARK: - GeminiService

    @Test func serviceLogContainsPromptLengthNotContent() async throws {
        var logs: [String] = []
        let transcript = "I am feeling very anxious about work today"
        let service = GeminiService(
            router: GeminiRecommendationRouter(
                requester: FakeRequester(response: highConfidenceJSON())
            ),
            apiKeyProvider: { "test-key" },
            logger: { logs.append($0) }
        )

        _ = try await service.recommend(transcript: transcript, history: [])

        let sendLog = try #require(logs.first)
        #expect(sendLog.contains("prompt length"))
        #expect(!sendLog.contains(transcript))
        #expect(!sendLog.contains("anxious"))
    }

    @Test func serviceLogContainsModelNameAndPracticeIDsNotResponseText() async throws {
        var logs: [String] = []
        let service = GeminiService(
            router: GeminiRecommendationRouter(
                requester: FakeRequester(response: highConfidenceJSON(practiceID: "box-breathing"))
            ),
            apiKeyProvider: { "test-key" },
            logger: { logs.append($0) }
        )

        _ = try await service.recommend(transcript: "I feel stressed", history: [])

        let successLog = try #require(logs.last)
        #expect(successLog.contains(GeminiRecommendationRouter.flashModel))
        #expect(successLog.contains("box-breathing"))
        #expect(!successLog.contains("rationale"))
        #expect(!successLog.contains("Because"))
    }

    // MARK: - GeminiRecommendationRouter

    @Test func routerEscalationLogContainsConfidenceNotPrompt() async throws {
        var logs: [String] = []
        let prompt = "My private check-in transcript"
        let router = GeminiRecommendationRouter(
            requester: FakeRequester(responses: [
                GeminiRecommendationRouter.flashModel: highConfidenceJSON(confidence: 0.4),
                GeminiRecommendationRouter.proModel: highConfidenceJSON(confidence: 0.9),
            ]),
            logger: { logs.append($0) }
        )

        _ = try await router.recommend(prompt: prompt, apiKey: "test-key")

        let escalationLog = try #require(logs.first)
        #expect(escalationLog.contains("0.4"))
        #expect(escalationLog.contains("escalating"))
        #expect(!escalationLog.contains(prompt))
        #expect(!escalationLog.contains("transcript"))
    }

    @Test func routerServerErrorLogContainsNoPromptContent() async throws {
        var logs: [String] = []
        let prompt = "My private check-in transcript"
        let router = GeminiRecommendationRouter(
            requester: FakeRequester(responses: [
                GeminiRecommendationRouter.flashModel: nil,
                GeminiRecommendationRouter.proModel: highConfidenceJSON(),
            ]),
            logger: { logs.append($0) }
        )

        _ = try await router.recommend(prompt: prompt, apiKey: "test-key")

        let fallbackLog = try #require(logs.first)
        #expect(fallbackLog.contains("server error"))
        #expect(!fallbackLog.contains(prompt))
    }
}

// MARK: - Helpers

private final class FakeRequester: GeminiModelRequesting {
    private let responses: [String: String]

    init(response: String) {
        self.responses = [
            GeminiRecommendationRouter.flashModel: response,
            GeminiRecommendationRouter.proModel: response,
        ]
    }

    init(responses: [String: String?]) {
        self.responses = responses.compactMapValues { $0 }
    }

    func request(
        prompt: String,
        apiKey: String,
        modelName: String,
        experiments: AnalysisLatencyExperimentSnapshot
    ) async throws -> String {
        if let response = responses[modelName] {
            return response
        }
        throw NSError(domain: "test", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "HTTP 503: unavailable"
        ])
    }
}

private func highConfidenceJSON(confidence: Double = 0.9, practiceID: String = "box-breathing") -> String {
    """
    {
      "rationale": "Because",
      "practices": [{"practice_id": "\(practiceID)", "relevance": "Relevant"}],
      "confidence": \(confidence)
    }
    """
}
