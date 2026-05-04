import Testing
@testable import sift

struct RecordingStateTests {

    @Test func sameCaseAreEqual() async {
        #expect(RecordingState.ready == RecordingState.ready)
        #expect(RecordingState.recording == RecordingState.recording)
        #expect(RecordingState.idle == RecordingState.idle)
    }

    @Test func differentCaseAreNotEqual() async {
        #expect(RecordingState.ready != RecordingState.recording)
        #expect(RecordingState.idle != RecordingState.loadingModel)
    }

    @Test func suggestingWithSameValuesAreEqual() async {
        let a = RecordingState.suggesting(transcript: "hello", practices: [])
        let b = RecordingState.suggesting(transcript: "hello", practices: [])
        #expect(a == b)
    }

    @Test func suggestingWithDifferentValuesAreNotEqual() async {
        let a = RecordingState.suggesting(transcript: "hello", practices: [])
        let b = RecordingState.suggesting(transcript: "world", practices: [])
        #expect(a != b)
    }
}
