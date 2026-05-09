import Testing
@testable import sift

struct SuggestionViewContentTests {
    @Test func rationaleLabelIsCoachingFlavored() {
        #expect(SuggestionViewContent.rationaleHeading == "Why these might fit")
        #expect(SuggestionViewContent.rationaleHeading != "Analysis")
    }

    @Test func relevanceLabelIsCoachingFlavoredAndAvailable() {
        #expect(SuggestionViewContent.relevanceHeading == "Why this might help")
        #expect(SuggestionViewContent.mainUserFacingCopy.contains("Why this might help"))
    }

    @Test func mainSuggestionCopyAvoidsModelRoutingLanguage() {
        let text = SuggestionViewContent.mainUserFacingCopy.joined(separator: "\n")

        #expect(!text.localizedCaseInsensitiveContains("Escalated to Pro model"))
        #expect(!text.localizedCaseInsensitiveContains("Gemini"))
        #expect(!text.localizedCaseInsensitiveContains("model"))
        #expect(!text.localizedCaseInsensitiveContains("Pro"))
        #expect(!text.localizedCaseInsensitiveContains("confidence"))
        #expect(!text.localizedCaseInsensitiveContains("routing"))
        #expect(!text.localizedCaseInsensitiveContains("debug"))
    }

    @Test func escalatedStateCanExistWithoutUserFacingEscalationCopy() {
        let practice = Practice(
            id: "test-practice",
            name: "Test Practice",
            category: "Grounding",
            labels: [],
            bestFor: [],
            keywords: [],
            summary: "A brief practice.",
            steps: ["Step one."],
            whyItHelps: "It helps.",
            durationMinutes: 3,
            intensity: "low",
            avoidWhen: []
        )

        let view = SuggestionView(
            transcript: "I feel unsettled.",
            practices: [practice],
            rationale: "A grounding practice may fit this check-in.",
            wasEscalated: true,
            relevanceByID: ["test-practice": "This may help you settle."],
            previouslyHelpfulIDs: [],
            onSelect: { _ in },
            onSkip: {}
        )

        #expect(view.wasEscalated)
        #expect(!SuggestionViewContent.mainUserFacingCopy.joined(separator: "\n").localizedCaseInsensitiveContains("escalated"))
    }
}
