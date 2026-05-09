import Testing
@testable import sift

struct CheckInRecoveryPresentationTests {
    @Test func microphoneRecoveryExplainsSettingsAction() {
        let presentation = CheckInRecoveryPresentation.microphonePermissionDenied

        #expect(presentation.kind == .microphonePermissionDenied)
        #expect(presentation.title == "Microphone access is off")
        #expect(presentation.message.contains("microphone"))
        #expect(presentation.primaryActionLabel == "Open Settings")
        #expect(presentation.primaryAction == .openSettings)
        #expect(presentation.secondaryActionLabel == "Try again")
        #expect(presentation.secondaryAction == .tryAgain)
    }

    @Test func modelLoadingRecoveryIsCalmAndRetryable() {
        let presentation = CheckInRecoveryPresentation.modelLoadingFailed

        #expect(presentation.message.contains("could not prepare speech recognition"))
        #expect(presentation.message.contains("Nothing was lost"))
        #expect(presentation.primaryActionLabel == "Try again")
        #expect(presentation.primaryAction == .retryModelLoading)
    }

    @Test func emptySpeechRecoveryAvoidsBlameAndRecordsAgain() {
        let presentation = CheckInRecoveryPresentation.emptySpeech

        #expect(presentation.title == "That did not come through")
        #expect(presentation.message.contains("did not do anything wrong"))
        #expect(presentation.message.contains("A sentence or two is enough"))
        #expect(presentation.primaryActionLabel == "Record again")
        #expect(presentation.primaryAction == .recordAgain)
    }

    @Test func analysisRecoveryPreservesTranscriptAndRetriesSuggestions() {
        let presentation = CheckInRecoveryPresentation.analysisFailed

        #expect(presentation.title == "Suggestions did not load")
        #expect(presentation.message.contains("check-in text is still here"))
        #expect(presentation.primaryActionLabel == "Try suggestions again")
        #expect(presentation.primaryAction == .retrySuggestions)
    }

    @Test func emptySuggestionsRecoveryAvoidsBlamingUser() {
        let presentation = CheckInRecoveryPresentation.emptySuggestions

        #expect(presentation.message.contains("could not find practices"))
        #expect(presentation.message.contains("does not mean you checked in incorrectly"))
        #expect(presentation.primaryAction == .retrySuggestions)
    }

    @Test func saveRecoveryPreservesReflectionAndRetriesSave() {
        let presentation = CheckInRecoveryPresentation.saveFailed

        #expect(presentation.title == "Reflection was not saved")
        #expect(presentation.message.contains("reflection is still here"))
        #expect(presentation.primaryActionLabel == "Try saving again")
        #expect(presentation.primaryAction == .trySavingAgain)
    }
}
