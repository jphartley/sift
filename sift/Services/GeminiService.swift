import Foundation

struct SessionHistoryEntry {
    let timestamp: Date
    let transcript: String
    let practiceName: String?
    let wasHelpful: Bool?
}

struct RecommendationResult {
    let rationale: String
    let practices: [(practiceID: String, relevance: String)]
    let confidence: Double
    let modelUsed: String
    let wasEscalated: Bool
}

enum GeminiError: LocalizedError, Equatable {
    case apiKeyMissing
    case networkError(String)
    case invalidResponse
    case jsonParseError
    case emptyPractices

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing: return "Gemini API key not configured"
        case .networkError(let message): return "Network error: \(message)"
        case .invalidResponse: return "Gemini returned an unexpected response"
        case .jsonParseError: return "Failed to parse Gemini response"
        case .emptyPractices: return "Gemini did not recommend any practices"
        }
    }
}

@Observable
final class GeminiService: RecommendationClient {

    private let promptBuilder: GeminiPromptBuilder
    private let router: GeminiRecommendationRouter
    private let apiKeyProvider: () -> String
    private let logger: (String) -> Void

    init(
        promptBuilder: GeminiPromptBuilder = GeminiPromptBuilder(),
        router: GeminiRecommendationRouter = GeminiRecommendationRouter(requester: LiveGeminiModelRequester()),
        apiKeyProvider: @escaping () -> String = { Secrets.geminiApiKey },
        logger: @escaping (String) -> Void = { print($0) }
    ) {
        self.promptBuilder = promptBuilder
        self.router = router
        self.apiKeyProvider = apiKeyProvider
        self.logger = logger
    }

    func recommend(
        transcript: String,
        history: [SessionHistoryEntry]
    ) async throws -> RecommendationResult {
        let key = apiKeyProvider()
        guard !key.isEmpty else {
            throw GeminiError.apiKeyMissing
        }

        let prompt = promptBuilder.buildPrompt(transcript: transcript, history: history)
        logger("[GeminiService] Sending to \(GeminiRecommendationRouter.flashModel) — prompt length: \(prompt.count) chars, history entries: \(history.count)")
        let result = try await router.recommend(prompt: prompt, apiKey: key)
        logger("[GeminiService] Success — model: \(result.modelUsed), confidence: \(result.confidence), escalated: \(result.wasEscalated), practices: \(result.practices.map(\.practiceID))")
        return result
    }
}
