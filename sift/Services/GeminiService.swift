import Foundation
import GoogleGenerativeAI

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

    private static let flashModel = "gemini-3-flash-preview"
    private static let proModel = "gemini-3.1-pro-preview"
    private static let confidenceThreshold = 0.7

    init() {}

    func recommend(
        transcript: String,
        history: [SessionHistoryEntry]
    ) async throws -> RecommendationResult {
        let key = Secrets.geminiApiKey
        guard !key.isEmpty else {
            throw GeminiError.apiKeyMissing
        }

        let prompt = buildPrompt(transcript: transcript, history: history)
        print("[GeminiService] Sending to \(Self.flashModel) — prompt length: \(prompt.count) chars, history entries: \(history.count)")

        do {
            let result = try await requestFlash(prompt: prompt, apiKey: key)
            if result.confidence >= Self.confidenceThreshold {
                return result
            }
            print("[GeminiService] Confidence \(result.confidence) below threshold \(Self.confidenceThreshold), escalating to Pro")
            return try await requestPro(prompt: prompt, apiKey: key)
        } catch {
            if isRetryableServerError(error) {
                print("[GeminiService] Flash failed with server error, falling back to Pro")
                return try await requestPro(prompt: prompt, apiKey: key)
            }
            throw error
        }
    }

    private func requestFlash(prompt: String, apiKey: String) async throws -> RecommendationResult {
        let model = makeFlashModel(apiKey: apiKey)
        return try await request(model: model, prompt: prompt, modelName: Self.flashModel, escalated: false)
    }

    private func requestPro(prompt: String, apiKey: String) async throws -> RecommendationResult {
        let model = makeProModel(apiKey: apiKey)
        return try await request(model: model, prompt: prompt, modelName: Self.proModel, escalated: true)
    }

    private func request(
        model: GenerativeModel,
        prompt: String,
        modelName: String,
        escalated: Bool
    ) async throws -> RecommendationResult {
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

        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rationale = json["rationale"] as? String,
              let practicesJSON = json["practices"] as? [[String: Any]],
              let confidence = json["confidence"] as? Double else {
            throw GeminiError.jsonParseError
        }

        var practices: [(practiceID: String, relevance: String)] = []
        for practiceJSON in practicesJSON {
            guard let id = practiceJSON["practice_id"] as? String,
                  let relevance = practiceJSON["relevance"] as? String else {
                continue
            }
            practices.append((practiceID: id, relevance: relevance))
        }

        if practices.isEmpty {
            throw GeminiError.emptyPractices
        }

        print("[GeminiService] Success — model: \(modelName), confidence: \(confidence), escalated: \(escalated), practices: \(practices.map(\.practiceID))")

        return RecommendationResult(
            rationale: rationale,
            practices: practices,
            confidence: confidence,
            modelUsed: modelName,
            wasEscalated: escalated
        )
    }

    private func makeFlashModel(apiKey: String) -> GenerativeModel {
        GenerativeModel(
            name: Self.flashModel,
            apiKey: apiKey,
            generationConfig: makeGenerationConfig(),
            systemInstruction: systemInstruction
        )
    }

    private func makeProModel(apiKey: String) -> GenerativeModel {
        GenerativeModel(
            name: Self.proModel,
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

    func buildPrompt(transcript: String, history: [SessionHistoryEntry]) -> String {
        var parts: [String] = []

        parts.append("## Practice Library")
        parts.append("")
        for practice in Practice.all {
            parts.append("- **\(practice.name)** (id: `\(practice.id)`, \(practice.category), ~\(practice.durationMinutes)m): \(practice.description)")
        }

        if !history.isEmpty {
            parts.append("")
            parts.append("## User History")
            parts.append("")
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short

            for (index, entry) in history.enumerated() {
                let dateStr = formatter.string(from: entry.timestamp)
                parts.append("### Session \(index + 1) (\(dateStr))")
                parts.append("What they said: \"\(entry.transcript)\"")
                if let name = entry.practiceName {
                    if let helpful = entry.wasHelpful {
                        parts.append("Practice tried: \(name) — \(helpful ? "Helpful" : "Not helpful")")
                    } else {
                        parts.append("Practice tried: \(name) — No rating")
                    }
                } else {
                    parts.append("No practice was tried.")
                }
                parts.append("")
            }
        }

        parts.append("## Current Check-In")
        parts.append("")
        parts.append("The user just said: \"\(transcript)\"")
        parts.append("")
        parts.append("Recommend 2-3 practices from the library above that would help them right now.")

        return parts.joined(separator: "\n")
    }

    func isRetryableServerError(_ error: Error) -> Bool {
        let description = error.localizedDescription.lowercased()
        let retryablePatterns = ["503", "429", "500", "502", "504", "unavailable", "high demand", "try again later", "rate limit", "too many requests", "internal server error"]
        return retryablePatterns.contains { description.contains($0) }
    }
}
