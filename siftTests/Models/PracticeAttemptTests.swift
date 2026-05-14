import Foundation
import Testing
@testable import sift

struct PracticeAttemptTests {

    @Test func defaultInitCompletedTrueWasHelpfulNil() async {
        let attempt = PracticeAttempt()
        #expect(attempt.completed == true)
        #expect(attempt.wasHelpful == nil)
    }

    @Test func customWasHelpfulTrueAndNotes() async {
        let attempt = PracticeAttempt(
            practiceID: "box-breathing",
            practiceName: "Box Breathing",
            wasHelpful: true,
            notes: "felt calm after"
        )
        #expect(attempt.wasHelpful == true)
        #expect(attempt.notes == "felt calm after")
    }

    @Test func wasHelpfulFalse() async {
        let attempt = PracticeAttempt(wasHelpful: false)
        #expect(attempt.wasHelpful == false)
    }

    @Test func practiceNameMatchesSourcePracticeName() {
        TestHelpers.setupPractices()
        let practice = Practice.all.first(where: { $0.id == "box-breathing" })!
        let attempt = PracticeAttempt(practiceID: practice.id, practiceName: practice.name)

        #expect(attempt.practiceName == practice.name)
        #expect(attempt.practiceName != attempt.practiceID)
    }

    @Test func defaultInitGeneratesUUID() async {
        let a = PracticeAttempt()
        let b = PracticeAttempt()
        #expect(a.id != b.id)
    }
}
