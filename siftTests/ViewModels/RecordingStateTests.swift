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

    @Test func practicingWithSameValuesAreEqual() async {
        let practice = Practice.all[0]
        let a = RecordingState.practicing(practice: practice, relevance: "Relevant")
        let b = RecordingState.practicing(practice: practice, relevance: "Relevant")
        #expect(a == b)
    }

    @Test func practicingWithDifferentValuesAreNotEqual() async {
        let a = RecordingState.practicing(practice: Practice.all[0], relevance: "Relevant")
        let b = RecordingState.practicing(practice: Practice.all[1], relevance: "Different")
        #expect(a != b)
    }

    @Test func reflectingWithSameValuesAreEqual() async {
        let a = RecordingState.reflecting(practiceName: "Box Breathing")
        let b = RecordingState.reflecting(practiceName: "Box Breathing")
        #expect(a == b)
    }

    @Test func reflectingWithDifferentValuesAreNotEqual() async {
        let a = RecordingState.reflecting(practiceName: "Box Breathing")
        let b = RecordingState.reflecting(practiceName: "Body Scan")
        #expect(a != b)
    }

    @Test func reflectingNotEqualToSuggesting() async {
        let a = RecordingState.reflecting(practiceName: "Box Breathing")
        let b = RecordingState.suggesting(transcript: "hello", practices: [], rationale: "", wasEscalated: false, relevanceByID: [:])
        #expect(a != b)
    }

    @Test func recoveryWithSamePresentationIsEqual() async {
        let a = RecordingState.recovery(.analysisFailed)
        let b = RecordingState.recovery(.analysisFailed)
        #expect(a == b)
    }

    @Test func recoveryWithDifferentPresentationIsNotEqual() async {
        let a = RecordingState.recovery(.analysisFailed)
        let b = RecordingState.recovery(.emptySpeech)
        #expect(a != b)
    }
}
