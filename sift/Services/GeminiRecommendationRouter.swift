import Foundation
import GoogleGenerativeAI

protocol GeminiModelRequesting: AnyObject {
    func request(prompt: String, apiKey: String, modelName: String) async throws -> String
}

struct GeminiRetryPolicy {
    func isRetryableServerError(_ error: Error) -> Bool {
        let description = error.localizedDescription.lowercased()
        let retryablePatterns = ["503", "429", "500", "502", "504", "unavailable", "high demand", "try again later", "rate limit", "too many requests", "internal server error"]
        return retryablePatterns.contains { description.contains($0) }
    }
}

struct GeminiRecommendationRouter {
    static let flashModel = "gemini-3-flash-preview"
    static let proModel = "gemini-3.1-pro-preview"
    static let confidenceThreshold = 0.7

    private let requester: GeminiModelRequesting
    private let parser: GeminiRecommendationParser
    private let retryPolicy: GeminiRetryPolicy

    init(
        requester: GeminiModelRequesting,
        parser: GeminiRecommendationParser = GeminiRecommendationParser(),
        retryPolicy: GeminiRetryPolicy = GeminiRetryPolicy()
    ) {
        self.requester = requester
        self.parser = parser
        self.retryPolicy = retryPolicy
    }

    func recommend(prompt: String, apiKey: String) async throws -> RecommendationResult {
        do {
            let flashText = try await requester.request(
                prompt: prompt,
                apiKey: apiKey,
                modelName: Self.flashModel
            )
            let flashResult = try parser.parse(
                text: flashText,
                modelUsed: Self.flashModel,
                wasEscalated: false
            )
            if flashResult.confidence >= Self.confidenceThreshold {
                return flashResult
            }
            print("[GeminiService] Confidence \(flashResult.confidence) below threshold \(Self.confidenceThreshold), escalating to Pro")
            return try await requestPro(prompt: prompt, apiKey: apiKey)
        } catch {
            if retryPolicy.isRetryableServerError(error) {
                print("[GeminiService] Flash failed with server error, falling back to Pro")
                return try await requestPro(prompt: prompt, apiKey: apiKey)
            }
            throw error
        }
    }

    private func requestPro(prompt: String, apiKey: String) async throws -> RecommendationResult {
        let proText = try await requester.request(
            prompt: prompt,
            apiKey: apiKey,
            modelName: Self.proModel
        )
        return try parser.parse(
            text: proText,
            modelUsed: Self.proModel,
            wasEscalated: true
        )
    }
}

final class LiveGeminiModelRequester: GeminiModelRequesting {
    func request(prompt: String, apiKey: String, modelName: String) async throws -> String {
        let model = makeModel(name: modelName, apiKey: apiKey)
        let response: GenerateContentResponse
        do {
            response = try await model.generateContent(prompt)
        } catch let error as GenerateContentError {
            print("[GeminiService] GenerateContentError for \(modelName): \(error)")
            switch error {
            case .responseStoppedEarly(let reason, let response):
                if let text = response.text {
                    print("[GeminiService] Partial response text: \(text)")
                }
                throw GeminiError.networkError("Response cut short: \(reason)")
            case .promptBlocked:
                throw GeminiError.networkError("Content blocked by safety filter")
            case .invalidAPIKey(let message):
                throw GeminiError.networkError("Invalid API key: \(message)")
            default:
                throw GeminiError.networkError(error.localizedDescription)
            }
        } catch {
            print("[GeminiService] Network error for \(modelName): \(error)")
            throw GeminiError.networkError(error.localizedDescription)
        }

        guard let text = response.text else {
            throw GeminiError.invalidResponse
        }

        return text
    }

    private func makeModel(name: String, apiKey: String) -> GenerativeModel {
        GenerativeModel(
            name: name,
            apiKey: apiKey,
            generationConfig: makeGenerationConfig(),
            systemInstruction: systemInstruction
        )
    }

    private func makeGenerationConfig() -> GenerationConfig {
        let responseSchema = Schema(
            type: .object,
            properties: [
                "rationale": Schema(
                    type: .string,
                    description: "Overall explanation for why these practices were chosen for this user right now"
                ),
                "practices": Schema(
                    type: .array,
                    description: "2-3 recommended practices in priority order",
                    items: Schema(
                        type: .object,
                        properties: [
                            "practice_id": Schema(
                                type: .string,
                                description: "The id of the practice from the library"
                            ),
                            "relevance": Schema(
                                type: .string,
                                description: "Why this specific practice is relevant to this user based on what they shared"
                            ),
                        ],
                        requiredProperties: ["practice_id", "relevance"]
                    )
                ),
                "confidence": Schema(
                    type: .number,
                    description: "Confidence score from 0.0 to 1.0 indicating how well these recommendations fit the user's needs. Use 1.0 for perfect fit, 0.0 for complete guess."
                ),
            ],
            requiredProperties: ["rationale", "practices", "confidence"]
        )

        return GenerationConfig(
            temperature: 0.3,
            maxOutputTokens: 4096,
            responseMIMEType: "application/json",
            responseSchema: responseSchema
        )
    }

    private var systemInstruction: String {
        """
        You are a compassionate wellness practice recommender. A user has just spoken about how \
        they're feeling. Your job is to:

        1. Listen carefully to what they shared
        2. Reflect back what you heard in a warm, empathetic way
        3. Recommend 2-3 practices from the library that would genuinely help them right now
        4. Explain why each practice is relevant to their specific situation

        Always acknowledge the user's feelings before making recommendations. Make the user \
        feel heard and understood. Your rationale should parrot back what they said and connect \
        it directly to your recommendations.

        Prioritize practices that have helped this user before, but don't force it if their \
        current situation calls for something different.
        """
    }
}
