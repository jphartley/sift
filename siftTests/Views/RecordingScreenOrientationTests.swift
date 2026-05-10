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

    @Test func setupCopyExplainsOnDeviceSpeechRecognitionAndFirstWait() {
        let presentation = RecordingScreenSetup.presentation(for: .loading)
        let copy = [
            presentation.title,
            presentation.message,
            presentation.status,
            presentation.note
        ].joined(separator: " ")

        #expect(copy.contains("on-device speech recognition"))
        #expect(copy.contains("transcribed on your phone"))
        #expect(copy.contains("First setup can take a little while"))
        #expect(!copy.localizedCaseInsensitiveContains("speech model"))
    }

    @Test func downloadSetupPresentationPreservesProgress() {
        let presentation = RecordingScreenSetup.presentation(for: .downloading(progress: 0.42))

        #expect(presentation.status.contains("Getting on-device speech recognition ready"))
        #expect(presentation.progress == .determinate(0.42))
    }

    @Test func localPreparationSetupPresentationUsesActiveLoading() {
        let presentation = RecordingScreenSetup.presentation(for: .loading)

        #expect(presentation.status.contains("Preparing speech recognition on device"))
        #expect(presentation.progress == .indeterminate)
    }

    @Test func recordingStartupCopyAcknowledgesFirstTap() {
        #expect(RecordingScreenRecordingStartup.status == "Getting microphone ready...")
    }
}
