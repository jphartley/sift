import Testing
@testable import sift

struct PracticeDetailViewTests {
    @Test func showsGentleNoteWhenHighIntensity() {
        let practice = makePractice(intensity: "high", avoidWhen: [])
        let view = PracticeDetailView(practice: practice, relevance: "", onBack: {}, onComplete: {})
        #expect(view.showsGentleNote)
    }

    @Test func highIntensityNoteIncludesGoSlowlyAndAdaptOrStop() {
        let practice = makePractice(intensity: "high", avoidWhen: [])
        let view = PracticeDetailView(practice: practice, relevance: "", onBack: {}, onComplete: {})
        #expect(view.gentleNoteHighIntensityText.contains("Go slowly"))
        #expect(view.gentleNoteHighIntensityText.contains("adapt"))
        #expect(view.gentleNoteHighIntensityText.contains("stop"))
    }

    @Test func showsGentleNoteWhenAvoidWhenNotEmpty() {
        let practice = makePractice(intensity: "low", avoidWhen: ["feeling dizzy"])
        let view = PracticeDetailView(practice: practice, relevance: "", onBack: {}, onComplete: {})
        #expect(view.showsGentleNote)
    }

    @Test func avoidWhenNoteIncludesAdaptOrStop() {
        let practice = makePractice(intensity: "low", avoidWhen: ["feeling dizzy"])
        let view = PracticeDetailView(practice: practice, relevance: "", onBack: {}, onComplete: {})
        #expect(view.gentleNoteAvoidWhenText.contains("feeling dizzy"))
        #expect(view.gentleNoteAvoidWhenText.contains("adapt or stop"))
    }

    @Test func hidesGentleNoteWhenLowIntensityAndNoAvoidWhen() {
        let practice = makePractice(intensity: "low", avoidWhen: [])
        let view = PracticeDetailView(practice: practice, relevance: "", onBack: {}, onComplete: {})
        #expect(!view.showsGentleNote)
    }

    @Test func hidesGentleNoteWhenMediumIntensityAndNoAvoidWhen() {
        let practice = makePractice(intensity: "medium", avoidWhen: [])
        let view = PracticeDetailView(practice: practice, relevance: "", onBack: {}, onComplete: {})
        #expect(!view.showsGentleNote)
    }

    private func makePractice(intensity: String, avoidWhen: [String]) -> Practice {
        Practice(
            id: "test-practice",
            name: "Test Practice",
            category: "Test",
            labels: [],
            bestFor: [],
            keywords: [],
            summary: "A test practice.",
            steps: ["Step one."],
            whyItHelps: "It helps.",
            durationMinutes: 5,
            intensity: intensity,
            avoidWhen: avoidWhen
        )
    }
}
