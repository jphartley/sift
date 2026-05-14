import Foundation
import Testing
@testable import sift

struct HistoryRowPresentationTests {

    @Test func pillTextReturnsPracticeNameNotSlug() {
        let attempt = PracticeAttempt(
            practiceID: "box-breathing",
            practiceName: "Box Breathing"
        )

        #expect(HistoryRowPresentation.pillText(for: attempt) == "Box Breathing")
        #expect(HistoryRowPresentation.pillText(for: attempt) != attempt.practiceID)
    }

    @Test func pillTextPassesThroughMultiWordNames() {
        let attempt = PracticeAttempt(
            practiceID: "five-senses-grounding",
            practiceName: "Five Senses Grounding"
        )

        #expect(HistoryRowPresentation.pillText(for: attempt) == "Five Senses Grounding")
    }
}
