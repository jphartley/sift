import Testing
@testable import sift

struct RecordingScreenOrientationTests {
    @Test func orientationCopyExplainsHowToBegin() {
        #expect(RecordingScreenOrientation.heading == "Take a moment to arrive")
        #expect(RecordingScreenOrientation.reassurance.contains("There is no right or wrong way to do this"))
        #expect(RecordingScreenOrientation.reassurance.contains("what feels most alive right now"))
        #expect(RecordingScreenOrientation.reassurance.contains("what kind of support you want"))
    }

    @Test func orientationCopyExplainsWhatHappensNext() {
        #expect(RecordingScreenOrientation.nextStep.contains("transcribe your voice on device"))
        #expect(RecordingScreenOrientation.nextStep.contains("reflect back what it heard"))
        #expect(RecordingScreenOrientation.nextStep.contains("suggest a few practices"))
    }

    @Test func starterPromptsAreExposed() {
        #expect(RecordingScreenOrientation.starterHeading == "You might start with:")
        #expect(RecordingScreenOrientation.starterPrompts == [
            "Right now I notice...",
            "What feels hard is...",
            "What I need is..."
        ])
    }

    @Test func returningGuidanceIsShorterThanFirstTimeOrientation() {
        #expect(RecordingScreenOrientation.returningHeading == "Check in again")
        #expect(RecordingScreenOrientation.returningGuidance.contains("Record another short voice note"))
        #expect(RecordingScreenOrientation.returningGuidance.contains("what feels most alive right now"))
        #expect(RecordingScreenOrientation.returningGuidance.contains("A minute is enough"))
        #expect(!RecordingScreenOrientation.returningGuidance.contains(RecordingScreenOrientation.starterPrompts[0]))
    }
}
