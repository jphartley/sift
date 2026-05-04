import Foundation
import Testing
@testable import sift

struct SessionTests {

    @Test func defaultInitHasEmptyAttempts() async {
        let session = Session()
        #expect(session.attempts.isEmpty)
    }

    @Test func customInitPreservesValues() async {
        let session = Session(
            transcript: "I feel stressed",
            audioDuration: 12.5,
            transcriptionDurationMs: 340
        )
        #expect(session.transcript == "I feel stressed")
        #expect(session.audioDuration == 12.5)
        #expect(session.transcriptionDurationMs == 340)
    }

    @Test func defaultInitGeneratesUUID() async {
        let a = Session()
        let b = Session()
        #expect(a.id != b.id)
    }
}
