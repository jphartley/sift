import Foundation

struct GeminiRecommendationParser {
    private struct ResponsePayload: Decodable {
        let rationale: String?
        let practices: [PracticePayload]?
        let confidence: Double?
    }

    private struct PracticePayload: Decodable {
        let practiceID: String?
        let relevance: String?

        enum CodingKeys: String, CodingKey {
            case practiceID = "practice_id"
            case relevance
        }
    }

    func parse(
        text: String,
        modelUsed: String,
        wasEscalated: Bool
    ) throws -> RecommendationResult {
        guard let data = text.data(using: .utf8) else {
            throw GeminiError.jsonParseError
        }

        let payload: ResponsePayload
        do {
            payload = try JSONDecoder().decode(ResponsePayload.self, from: data)
        } catch {
            throw GeminiError.jsonParseError
        }

        guard let rationale = payload.rationale,
              let practicesPayload = payload.practices,
              let confidence = payload.confidence else {
            throw GeminiError.jsonParseError
        }

        let practices = practicesPayload.compactMap { practice -> (practiceID: String, relevance: String)? in
            guard let id = practice.practiceID,
                  let relevance = practice.relevance else {
                return nil
            }
            return (practiceID: id, relevance: relevance)
        }

        if practices.isEmpty {
            throw GeminiError.emptyPractices
        }

        return RecommendationResult(
            rationale: rationale,
            practices: practices,
            confidence: confidence,
            modelUsed: modelUsed,
            wasEscalated: wasEscalated
        )
    }
}
