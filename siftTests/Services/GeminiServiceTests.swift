import Foundation
import Testing
@testable import sift

struct GeminiServiceTests {

    @Test func errorApiKeyMissingDescription() {
        let error = GeminiError.apiKeyMissing
        #expect(error.errorDescription == "Gemini API key not configured")
    }

    @Test func errorNetworkErrorDescription() {
        let error = GeminiError.networkError("timeout")
        #expect(error.errorDescription == "Network error: timeout")
    }

    @Test func errorInvalidResponseDescription() {
        let error = GeminiError.invalidResponse
        #expect(error.errorDescription == "Gemini returned an unexpected response")
    }

    @Test func errorJsonParseErrorDescription() {
        let error = GeminiError.jsonParseError
        #expect(error.errorDescription == "Failed to parse Gemini response")
    }

    @Test func errorEmptyPracticesDescription() {
        let error = GeminiError.emptyPractices
        #expect(error.errorDescription == "Gemini did not recommend any practices")
    }

    @Test func sessionHistoryEntryDefaults() {
        let entry = SessionHistoryEntry(
            timestamp: Date(),
            transcript: "hello",
            practiceName: nil,
            wasHelpful: nil
        )
        #expect(entry.transcript == "hello")
        #expect(entry.practiceName == nil)
        #expect(entry.wasHelpful == nil)
    }

    @Test func recommendationResultProperties() {
        let result = RecommendationResult(
            rationale: "Because you mentioned stress",
            practices: [("box-breathing", "This helps with stress")],
            confidence: 0.85,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        )
        #expect(result.rationale == "Because you mentioned stress")
        #expect(result.practices.count == 1)
        #expect(result.practices[0].practiceID == "box-breathing")
        #expect(result.practices[0].relevance == "This helps with stress")
        #expect(result.confidence == 0.85)
        #expect(result.modelUsed == "gemini-3-flash-preview")
        #expect(result.wasEscalated == false)
    }

    @Test func recommendationResultWithEscalation() {
        let result = RecommendationResult(
            rationale: "Deep analysis needed",
            practices: [("morning-pages", "Write it out")],
            confidence: 0.5,
            modelUsed: "gemini-3.1-pro-preview",
            wasEscalated: true
        )
        #expect(result.wasEscalated == true)
        #expect(result.modelUsed == "gemini-3.1-pro-preview")
    }

    @Test func secretsApiKeyIsAccessible() {
        let key = Secrets.geminiApiKey
        #expect(type(of: key) == String.self)
    }
}
