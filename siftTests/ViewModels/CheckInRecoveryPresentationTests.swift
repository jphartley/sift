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

    // MARK: - Structural invariants

    @Test func secondaryLabelAndActionAreAlwaysPaired() {
        // A presentation must never have a label without an action or vice versa
        let all: [CheckInRecoveryPresentation] = [
            .microphonePermissionDenied, .modelLoadingFailed, .emptySpeech,
            .analysisFailed, .emptySuggestions, .saveFailed
        ]
        for presentation in all {
            let hasLabel = presentation.secondaryActionLabel != nil
            let hasAction = presentation.secondaryAction != nil
            #expect(hasLabel == hasAction, "secondaryActionLabel and secondaryAction must be both set or both nil for kind \(presentation.kind)")
        }
    }

    @Test func eachKindMapsToExpectedPrimaryAction() {
        let expected: [(CheckInRecoveryPresentation, CheckInRecoveryPresentation.Action)] = [
            (.microphonePermissionDenied, .openSettings),
            (.modelLoadingFailed,         .retryModelLoading),
            (.emptySpeech,                .recordAgain),
            (.analysisFailed,             .retrySuggestions),
            (.emptySuggestions,           .retrySuggestions),
            (.saveFailed,                 .trySavingAgain),
        ]
        for (presentation, expectedAction) in expected {
            #expect(presentation.primaryAction == expectedAction, "kind \(presentation.kind) should use \(expectedAction)")
        }
    }
}
