import Foundation

struct CheckInRecoveryPresentation: Equatable {
    enum Kind: Equatable {
        case microphonePermissionDenied
        case modelLoadingFailed
        case emptySpeech
        case analysisFailed
        case emptySuggestions
        case saveFailed
    }

    enum Action: Equatable {
        case openSettings
        case tryAgain
        case retryModelLoading
        case retrySuggestions
        case recordAgain
        case trySavingAgain
    }

    let kind: Kind
    let title: String
    let message: String
    let primaryActionLabel: String
    let primaryAction: Action
    let secondaryActionLabel: String?
    let secondaryAction: Action?

    static let microphonePermissionDenied = CheckInRecoveryPresentation(
        kind: .microphonePermissionDenied,
        title: "Microphone access is off",
        message: "Sift needs the microphone to record a check-in. You can turn it on in Settings, then come back here.",
        primaryActionLabel: "Open Settings",
        primaryAction: .openSettings,
        secondaryActionLabel: "Try again",
        secondaryAction: .tryAgain
    )

    static let modelLoadingFailed = CheckInRecoveryPresentation(
        kind: .modelLoadingFailed,
        title: "Speech recognition did not load",
        message: "Sift could not prepare speech recognition. Nothing was lost.",
        primaryActionLabel: "Try again",
        primaryAction: .retryModelLoading,
        secondaryActionLabel: nil,
        secondaryAction: nil
    )

    static let emptySpeech = CheckInRecoveryPresentation(
        kind: .emptySpeech,
        title: "That did not come through",
        message: "No worries. You did not do anything wrong. Try another short check-in when you are ready. A sentence or two is enough.",
        primaryActionLabel: "Record again",
        primaryAction: .recordAgain,
        secondaryActionLabel: nil,
        secondaryAction: nil
    )

    static let analysisFailed = CheckInRecoveryPresentation(
        kind: .analysisFailed,
        title: "Suggestions did not load",
        message: "Your check-in text is still here. This is usually a connection or AI service hiccup.",
        primaryActionLabel: "Try suggestions again",
        primaryAction: .retrySuggestions,
        secondaryActionLabel: nil,
        secondaryAction: nil
    )

    static let emptySuggestions = CheckInRecoveryPresentation(
        kind: .emptySuggestions,
        title: "No practices came through",
        message: "Sift could not find practices to show this time. That does not mean you checked in incorrectly.",
        primaryActionLabel: "Try suggestions again",
        primaryAction: .retrySuggestions,
        secondaryActionLabel: nil,
        secondaryAction: nil
    )

    static let saveFailed = CheckInRecoveryPresentation(
        kind: .saveFailed,
        title: "Reflection was not saved",
        message: "Your reflection is still here. Try saving again before leaving this screen.",
        primaryActionLabel: "Try saving again",
        primaryAction: .trySavingAgain,
        secondaryActionLabel: nil,
        secondaryAction: nil
    )
}
