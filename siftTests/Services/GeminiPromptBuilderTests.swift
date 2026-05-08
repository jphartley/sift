import Foundation
import Testing
@testable import sift

struct GeminiPromptBuilderTests {

    init() {
        TestHelpers.setupPractices()
    }

    @Test func promptIncludesTranscript() {
        let builder = GeminiPromptBuilder()
        let prompt = builder.buildPrompt(transcript: "I feel stressed", history: [])

        #expect(prompt.contains("I feel stressed"))
        #expect(prompt.contains("Current Check-In"))
    }

    @Test func promptIncludesPracticeLibrary() {
        let builder = GeminiPromptBuilder()
        let prompt = builder.buildPrompt(transcript: "test", history: [])

        #expect(prompt.contains("Practice Library"))
        #expect(prompt.contains("Box Breathing"))
        #expect(prompt.contains("Body Scan"))
        #expect(prompt.contains("Morning Pages"))
    }

    @Test func promptIncludesPracticeDetails() {
        let builder = GeminiPromptBuilder()
        let prompt = builder.buildPrompt(transcript: "test", history: [])

        #expect(prompt.contains("Breathwork"))
        #expect(prompt.contains("~3m"))
        #expect(prompt.contains("box-breathing"))
    }

    @Test func promptWithEmptyHistoryHasNoHistorySection() {
        let builder = GeminiPromptBuilder()
        let prompt = builder.buildPrompt(transcript: "test", history: [])

        #expect(!prompt.contains("User History"))
    }

    @Test func promptIncludesHistorySection() {
        let builder = GeminiPromptBuilder()
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
        let prompt = builder.buildPrompt(transcript: "current", history: history)

        #expect(prompt.contains("User History"))
        #expect(prompt.contains("I was tired"))
        #expect(prompt.contains("Body Scan"))
        #expect(prompt.contains("Helpful"))
        #expect(prompt.contains("Feeling good today"))
        #expect(prompt.contains("No practice was tried"))
    }

    @Test func promptIncludesNotHelpfulRating() {
        let builder = GeminiPromptBuilder()
        let history = [
            SessionHistoryEntry(
                timestamp: Date(),
                transcript: "test",
                practiceName: "Box Breathing",
                wasHelpful: false
            )
        ]
        let prompt = builder.buildPrompt(transcript: "current", history: history)

        #expect(prompt.contains("Not helpful"))
    }

    @Test func promptIncludesNoRatingEntry() {
        let builder = GeminiPromptBuilder()
        let history = [
            SessionHistoryEntry(
                timestamp: Date(),
                transcript: "test",
                practiceName: "Call a Friend",
                wasHelpful: nil
            )
        ]
        let prompt = builder.buildPrompt(transcript: "current", history: history)

        #expect(prompt.contains("No rating"))
    }

    @Test func promptSizeDoesNotExplodeWithLargeHistory() {
        let builder = GeminiPromptBuilder()
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
        let prompt = builder.buildPrompt(transcript: transcript, history: history)
        #expect(prompt.count < 100_000)
    }

    @Test func promptWithEmptyTranscriptStillBuilds() {
        let builder = GeminiPromptBuilder()
        let prompt = builder.buildPrompt(transcript: "", history: [])

        #expect(prompt.contains("Current Check-In"))
        #expect(!prompt.isEmpty)
    }
}
