import Foundation
import Testing
@testable import sift

struct GeminiRecommendationRouterTests {

    @Test func highConfidenceFlashDoesNotRequestPro() async throws {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .success(responseJSON(confidence: 0.85))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        let result = try await router.recommend(prompt: "prompt", apiKey: "key")

        #expect(result.modelUsed == GeminiRecommendationRouter.flashModel)
        #expect(!result.wasEscalated)
        #expect(requester.requestedModels == [GeminiRecommendationRouter.flashModel])
    }

    @Test func lowConfidenceFlashEscalatesToPro() async throws {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .success(responseJSON(confidence: 0.4)),
            GeminiRecommendationRouter.proModel: .success(responseJSON(confidence: 0.6, practiceID: "body-scan"))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        let result = try await router.recommend(prompt: "prompt", apiKey: "key")

        #expect(result.modelUsed == GeminiRecommendationRouter.proModel)
        #expect(result.wasEscalated)
        #expect(result.practices[0].practiceID == "body-scan")
        #expect(requester.requestedModels == [
            GeminiRecommendationRouter.flashModel,
            GeminiRecommendationRouter.proModel
        ])
    }

    @Test func confidence0_69EscalatesToPro() async throws {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .success(responseJSON(confidence: 0.69)),
            GeminiRecommendationRouter.proModel: .success(responseJSON(confidence: 0.8, practiceID: "body-scan"))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        let result = try await router.recommend(prompt: "prompt", apiKey: "key")

        #expect(result.wasEscalated)
        #expect(requester.requestedModels == [
            GeminiRecommendationRouter.flashModel,
            GeminiRecommendationRouter.proModel
        ])
    }

    @Test func confidence0_70DoesNotEscalate() async throws {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .success(responseJSON(confidence: 0.70))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        let result = try await router.recommend(prompt: "prompt", apiKey: "key")

        #expect(!result.wasEscalated)
        #expect(requester.requestedModels == [GeminiRecommendationRouter.flashModel])
    }

    @Test func confidence0_71DoesNotEscalate() async throws {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .success(responseJSON(confidence: 0.71))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        let result = try await router.recommend(prompt: "prompt", apiKey: "key")

        #expect(!result.wasEscalated)
        #expect(requester.requestedModels == [GeminiRecommendationRouter.flashModel])
    }

    @Test func retryableFlashFailureFallsBackToPro() async throws {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .failure(testError("HTTP 503: unavailable")),
            GeminiRecommendationRouter.proModel: .success(responseJSON(confidence: 0.55, practiceID: "morning-pages"))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        let result = try await router.recommend(prompt: "prompt", apiKey: "key")

        #expect(result.modelUsed == GeminiRecommendationRouter.proModel)
        #expect(result.wasEscalated)
        #expect(result.practices[0].practiceID == "morning-pages")
        #expect(requester.requestedModels == [
            GeminiRecommendationRouter.flashModel,
            GeminiRecommendationRouter.proModel
        ])
    }

    @Test func nonRetryableFlashFailureDoesNotRequestPro() async {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .failure(testError("Invalid API key"))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        do {
            _ = try await router.recommend(prompt: "prompt", apiKey: "key")
            Issue.record("Expected router to throw")
        } catch {
            #expect(requester.requestedModels == [GeminiRecommendationRouter.flashModel])
        }
    }

    @Test func proFailureAfterFallbackIsSurfaced() async {
        let requester = FakeGeminiModelRequester(responses: [
            GeminiRecommendationRouter.flashModel: .failure(testError("rate limit exceeded")),
            GeminiRecommendationRouter.proModel: .failure(testError("pro unavailable"))
        ])
        let router = GeminiRecommendationRouter(requester: requester)

        do {
            _ = try await router.recommend(prompt: "prompt", apiKey: "key")
            Issue.record("Expected router to throw")
        } catch {
            #expect(error.localizedDescription.contains("pro unavailable"))
            #expect(requester.requestedModels == [
                GeminiRecommendationRouter.flashModel,
                GeminiRecommendationRouter.proModel
            ])
        }
    }

    @Test func retryPolicyRecognizesRetryableErrors() {
        let retryPolicy = GeminiRetryPolicy()
        let errors = [
            testError("HTTP 503: The service is currently experiencing high demand"),
            testError("rate limit exceeded"),
            testError("Internal server error"),
            testError("502 Bad Gateway"),
            testError("504 Gateway Timeout"),
            testError("Service unavailable, try again later"),
            testError("Too many requests, please try again later"),
            testError("SERVICE UNAVAILABLE")
        ]

        for error in errors {
            #expect(retryPolicy.isRetryableServerError(error))
        }
    }

    @Test func retryPolicyRejectsNonRetryableErrors() {
        let retryPolicy = GeminiRetryPolicy()
        let errors = [
            testError("Not found"),
            testError("Bad request: invalid model name"),
            testError("Permission denied"),
            testError("Invalid API key")
        ]

        for error in errors {
            #expect(!retryPolicy.isRetryableServerError(error))
        }
    }
}

private final class FakeGeminiModelRequester: GeminiModelRequesting {
    enum FakeResult {
        case success(String)
        case failure(Error)
    }

    private let responses: [String: FakeResult]
    private(set) var requestedModels: [String] = []

    init(responses: [String: FakeResult]) {
        self.responses = responses
    }

    func request(prompt: String, apiKey: String, modelName: String) async throws -> String {
        requestedModels.append(modelName)
        switch responses[modelName] {
        case .success(let text):
            return text
        case .failure(let error):
            throw error
        case nil:
            throw testError("No fake response for \(modelName)")
        }
    }
}

private func responseJSON(
    confidence: Double,
    practiceID: String = "box-breathing"
) -> String {
    """
    {
      "rationale": "Because",
      "practices": [
        {
          "practice_id": "\(practiceID)",
          "relevance": "Relevant"
        }
      ],
      "confidence": \(confidence)
    }
    """
}

private func testError(_ message: String) -> NSError {
    NSError(domain: "test", code: -1, userInfo: [
        NSLocalizedDescriptionKey: message
    ])
}
