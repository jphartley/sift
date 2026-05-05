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
        let a = RecordingState.suggesting(transcript: "hello", practices: [], rationale: "", wasEscalated: false, relevanceByID: [:])
        let b = RecordingState.suggesting(transcript: "hello", practices: [], rationale: "", wasEscalated: false, relevanceByID: [:])
        #expect(a == b)
    }

    @Test func suggestingWithDifferentValuesAreNotEqual() async {
        let a = RecordingState.suggesting(transcript: "hello", practices: [], rationale: "", wasEscalated: false, relevanceByID: [:])
        let b = RecordingState.suggesting(transcript: "world", practices: [], rationale: "", wasEscalated: false, relevanceByID: [:])
        #expect(a != b)
    }

    @Test func analyzingEqualsAnalyzing() async {
        #expect(RecordingState.analyzing == RecordingState.analyzing)
    }

    @Test func analyzingNotEqualToTranscribing() async {
        #expect(RecordingState.analyzing != RecordingState.transcribing)
    }

    @Test func suggestingWithRationaleAreEqual() async {
        let a = RecordingState.suggesting(transcript: "hello", practices: [], rationale: "test", wasEscalated: false, relevanceByID: [:])
        let b = RecordingState.suggesting(transcript: "hello", practices: [], rationale: "test", wasEscalated: false, relevanceByID: [:])
        #expect(a == b)
    }
}
