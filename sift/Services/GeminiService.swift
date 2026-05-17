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
    private let validator: RecommendationConstraintValidator
    private let apiKeyProvider: () -> String
    private let logger: (String) -> Void
    private let recorder: MetricRecorder?
    private let experimentStore: AnalysisLatencyExperimentStore?

    convenience init(recorder: MetricRecorder?, experimentStore: AnalysisLatencyExperimentStore? = nil) {
        self.init(
            promptBuilder: GeminiPromptBuilder(),
            router: GeminiRecommendationRouter(requester: LiveGeminiModelRequester(), recorder: recorder),
            validator: RecommendationConstraintValidator(),
            apiKeyProvider: { Secrets.geminiApiKey },
            logger: { print($0) },
            recorder: recorder,
            experimentStore: experimentStore
        )
    }

    init(
        promptBuilder: GeminiPromptBuilder = GeminiPromptBuilder(),
        router: GeminiRecommendationRouter = GeminiRecommendationRouter(requester: LiveGeminiModelRequester()),
        validator: RecommendationConstraintValidator = RecommendationConstraintValidator(),
        apiKeyProvider: @escaping () -> String = { Secrets.geminiApiKey },
        logger: @escaping (String) -> Void = { print($0) },
        recorder: MetricRecorder? = nil,
        experimentStore: AnalysisLatencyExperimentStore? = nil
    ) {
        self.promptBuilder = promptBuilder
        self.router = router
        self.validator = validator
        self.apiKeyProvider = apiKeyProvider
        self.logger = logger
        self.recorder = recorder
        self.experimentStore = experimentStore
    }

    func recommend(
        transcript: String,
        history: [SessionHistoryEntry],
        profile: UserPracticeProfile? = nil
    ) async throws -> RecommendationResult {
        let experiments = experimentStore?.snapshot ?? .baseline
        if let recorder {
            return try await recorder.time(name: "gemini.total", metadata: experiments.metricMetadata) {
                try await recommendBody(transcript: transcript, history: history, profile: profile, experiments: experiments)
            }
        }
        return try await recommendBody(transcript: transcript, history: history, profile: profile, experiments: experiments)
    }

    private func recommendBody(
        transcript: String,
        history: [SessionHistoryEntry],
        profile: UserPracticeProfile?,
        experiments: AnalysisLatencyExperimentSnapshot
    ) async throws -> RecommendationResult {
        let key = apiKeyProvider()
        guard !key.isEmpty else {
            throw GeminiError.apiKeyMissing
        }

        let prompt = promptBuilder.buildPrompt(transcript: transcript, history: history, profile: profile, experiments: experiments)
        logger("[GeminiService] Sending to \(experiments.flashModelName) — prompt length: \(prompt.count) chars, history entries: \(history.count)")
        let result = try await router.recommend(prompt: prompt, apiKey: key, experiments: experiments)
        let validatedResult = try validator.validate(result, profile: profile, transcript: transcript)
        logger("[GeminiService] Success — model: \(validatedResult.modelUsed), confidence: \(validatedResult.confidence), escalated: \(validatedResult.wasEscalated), practices: \(validatedResult.practices.map(\.practiceID))")
        return validatedResult
    }
}
