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

    @Test func promptIncludesTranscript() {
        let service = GeminiService()
        let prompt = service.buildPrompt(transcript: "I feel stressed", history: [])

        #expect(prompt.contains("I feel stressed"))
        #expect(prompt.contains("Current Check-In"))
    }

    @Test func promptIncludesPracticeLibrary() {
        let service = GeminiService()
        let prompt = service.buildPrompt(transcript: "test", history: [])

        #expect(prompt.contains("Practice Library"))
        #expect(prompt.contains("Box Breathing"))
        #expect(prompt.contains("Body Scan"))
        #expect(prompt.contains("Morning Pages"))
    }

    @Test func promptIncludesPracticeDetails() {
        let service = GeminiService()
        let prompt = service.buildPrompt(transcript: "test", history: [])

        #expect(prompt.contains("Breathwork"))
        #expect(prompt.contains("~3m"))
        #expect(prompt.contains("box-breathing"))
    }

    @Test func promptWithEmptyHistoryHasNoHistorySection() {
        let service = GeminiService()
        let prompt = service.buildPrompt(transcript: "test", history: [])

        #expect(!prompt.contains("User History"))
    }

    @Test func promptIncludesHistorySection() {
        let service = GeminiService()
        let history = [
            SessionHistoryEntry(
                timestamp: Date(timeIntervalSince1970: 0),
                transcript: "I was tired",
                practiceName: "Body Scan",
                wasHelpful: true
            ),
            SessionHistoryEntry(
                timestamp: Date(timeIntervalSince1970: 86400),
                transcript: "Feeling good today",
                practiceName: nil,
                wasHelpful: nil
            )
        ]
        let prompt = service.buildPrompt(transcript: "current", history: history)

        #expect(prompt.contains("User History"))
        #expect(prompt.contains("I was tired"))
        #expect(prompt.contains("Body Scan"))
        #expect(prompt.contains("Helpful"))
        #expect(prompt.contains("Feeling good today"))
        #expect(prompt.contains("No practice was tried"))
    }

    @Test func promptIncludesNotHelpfulRating() {
        let service = GeminiService()
        let history = [
            SessionHistoryEntry(
                timestamp: Date(),
                transcript: "test",
                practiceName: "Box Breathing",
                wasHelpful: false
            )
        ]
        let prompt = service.buildPrompt(transcript: "current", history: history)

        #expect(prompt.contains("Not helpful"))
    }

    @Test func promptIncludesNoRatingEntry() {
        let service = GeminiService()
        let history = [
            SessionHistoryEntry(
                timestamp: Date(),
                transcript: "test",
                practiceName: "Call a Friend",
                wasHelpful: nil
            )
        ]
        let prompt = service.buildPrompt(transcript: "current", history: history)

        #expect(prompt.contains("No rating"))
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

    @Test func retryableError503() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 503, userInfo: [
            NSLocalizedDescriptionKey: "HTTP 503: The service is currently experiencing high demand"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func retryableError429() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 429, userInfo: [
            NSLocalizedDescriptionKey: "rate limit exceeded"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func retryableError500() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 500, userInfo: [
            NSLocalizedDescriptionKey: "Internal server error"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func retryableError502() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 502, userInfo: [
            NSLocalizedDescriptionKey: "502 Bad Gateway"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func retryableError504() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 504, userInfo: [
            NSLocalizedDescriptionKey: "504 Gateway Timeout"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func retryableErrorUnavailable() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Service unavailable, try again later"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func retryableErrorHighDemand() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "This model is currently experiencing high demand. Spikes in demand are usually temporary."
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func retryableErrorTooManyRequests() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Too many requests, please try again later"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func notRetryableError404() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 404, userInfo: [
            NSLocalizedDescriptionKey: "Not found"
        ])
        #expect(!service.isRetryableServerError(error))
    }

    @Test func notRetryableError400() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 400, userInfo: [
            NSLocalizedDescriptionKey: "Bad request: invalid model name"
        ])
        #expect(!service.isRetryableServerError(error))
    }

    @Test func notRetryableError403() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 403, userInfo: [
            NSLocalizedDescriptionKey: "Permission denied"
        ])
        #expect(!service.isRetryableServerError(error))
    }

    @Test func notRetryableErrorInvalidAPIKey() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 401, userInfo: [
            NSLocalizedDescriptionKey: "Invalid API key"
        ])
        #expect(!service.isRetryableServerError(error))
    }

    @Test func retryableErrorCaseInsensitive() {
        let service = GeminiService()
        let error = NSError(domain: "test", code: 503, userInfo: [
            NSLocalizedDescriptionKey: "SERVICE UNAVAILABLE"
        ])
        #expect(service.isRetryableServerError(error))
    }

    @Test func promptSizeDoesNotExplodeWithLargeHistory() {
        let service = GeminiService()
        let transcript = "I am feeling quite stressed about work deadlines."
        var history: [SessionHistoryEntry] = []
        for i in 0..<50 {
            history.append(SessionHistoryEntry(
                timestamp: Date(timeIntervalSinceNow: -Double(i * 3600)),
                transcript: transcript,
                practiceName: i % 3 == 0 ? "Box Breathing" : nil,
                wasHelpful: i % 2 == 0 ? true : nil
            ))
        }
        let prompt = service.buildPrompt(transcript: transcript, history: history)
        #expect(prompt.count < 100_000)
    }

    @Test func promptWithEmptyTranscriptStillBuilds() {
        let service = GeminiService()
        let prompt = service.buildPrompt(transcript: "", history: [])
        #expect(prompt.contains("Current Check-In"))
        #expect(!prompt.isEmpty)
    }

    @Test func secretsApiKeyIsAccessible() {
        let key = Secrets.geminiApiKey
        #expect(type(of: key) == String.self)
    }
}
