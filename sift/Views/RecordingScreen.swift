import SwiftUI
import SwiftData
import UIKit

public enum RecordingScreenOrientation {
    public static let heading = "Take a moment to arrive"
    public static let reassurance = "There is no right or wrong way to do this. Speak for about a minute about what feels most alive right now: what happened, how it feels, or what kind of support you want."
    public static let nextStep = "Sift will transcribe your voice on device, reflect back what it heard, and suggest a few practices you can choose from."
    public static let returningHeading = "Check in again"
    public static let returningGuidance = "Record another short voice note about what feels most alive right now. A minute is enough."
    public static let starterHeading = "You might start with:"
    public static let starterPrompts = [
        "Right now I notice...",
        "What feels hard is...",
        "What I need is..."
    ]
}

enum RecordingScreenSetup {
    enum Progress: Equatable {
        case determinate(Double)
        case indeterminate
    }

    struct Presentation: Equatable {
        let title: String
        let message: String
        let status: String
        let note: String
        let progress: Progress
    }

    static func presentation(for modelState: ModelState) -> Presentation {
        let title = "Getting Sift ready"
        let message = "Sift is preparing on-device speech recognition so your voice can be transcribed on your phone."
        let note = "First setup can take a little while. After that, opening Sift should be faster."

        switch modelState {
        case .downloading(let progress):
            return Presentation(
                title: title,
                message: message,
                status: "Getting on-device speech recognition ready...",
                note: note,
                progress: .determinate(progress)
            )
        case .loading:
            return Presentation(
                title: title,
                message: message,
                status: "Preparing speech recognition on device...",
                note: note,
                progress: .indeterminate
            )
        case .notLoaded:
            return Presentation(
                title: title,
                message: message,
                status: "Starting setup...",
                note: note,
                progress: .indeterminate
            )
        case .ready, .failed:
            return Presentation(
                title: title,
                message: message,
                status: "",
                note: note,
                progress: .indeterminate
            )
        }
    }
}

enum RecordingScreenRecordingStartup {
    static let status = "Getting microphone ready..."
}

enum RecordingScreenSettings {
    static let appSettingsURL = URL(string: UIApplication.openSettingsURLString)
}

struct RecordingScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TranscriptionService.self) private var transcriptionService
    @Environment(GeminiService.self) private var geminiService
    @State private var viewModel = RecordingViewModel()

    var body: some View {
        Group {
            switch transcriptionService.modelState {
            case .downloading, .loading, .notLoaded:
                loadingView
            case .failed:
                recoveryView(.modelLoadingFailed) {
                    Task { await transcriptionService.loadModel() }
                }
            case .ready:
                switch viewModel.state {
                case .idle, .loadingModel, .ready:
                    readyView
                case .preparingToRecord:
                    preparingToRecordView
                case .recording:
                    recordingView
                case .transcribing:
                    transcribingView
                case .analyzing:
                    AnalyzingView(transcript: viewModel.lastTranscript)
                case .suggesting(let transcript, let practices, let rationale, let wasEscalated, let relevanceByID):
                    SuggestionView(
                        transcript: transcript,
                        practices: practices,
                        rationale: rationale,
                        wasEscalated: wasEscalated,
                        relevanceByID: relevanceByID,
                        previouslyHelpfulIDs: previouslyHelpfulIDs(),
                        hasPriorSessions: hasPriorSessions(),
                        onSelect: { practice in
                            viewModel.selectPractice(practice: practice, relevance: relevanceByID[practice.id])
                        },
                        onSkip: { viewModel.skipSuggestions() }
                    )
                case .practicing(let practice, let relevance):
                    PracticeDetailView(
                        practice: practice,
                        relevance: relevance,
                        onBack: { viewModel.dismissPractice() },
                        onComplete: { viewModel.completeSelectedPractice() }
                    )
                case .reflecting(let practiceName):
                    ReflectionView(
                        practiceName: practiceName,
                        onSave: { wasHelpful, notes in
                            viewModel.completeReflection(wasHelpful: wasHelpful, notes: notes)
                        }
                    )
                case .recovery(let presentation):
                    recoveryView(presentation)
                case .error(let message):
                    errorView(message) { viewModel.retryAnalysis() }
                }
            }
        }
        .task {
            viewModel.configure(
                sessionStore: SwiftDataSessionStore(modelContext: modelContext),
                transcriptionService: transcriptionService,
                recommendationClient: geminiService
            )
            await viewModel.setup()
        }
        .onDisappear {
            viewModel.tearDown()
        }
    }

    private func previouslyHelpfulIDs() -> Set<String> {
        let descriptor = FetchDescriptor<PracticeAttempt>(
            predicate: #Predicate { $0.wasHelpful == true },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let helpful = (try? modelContext.fetch(descriptor)) ?? []
        return Set(helpful.map(\.practiceID))
    }

    private func hasPriorSessions() -> Bool {
        let descriptor = FetchDescriptor<Session>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    private var loadingView: some View {
        let presentation = RecordingScreenSetup.presentation(for: transcriptionService.modelState)
        return ScrollView {
            VStack(spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 60)

                BreathingDot()
                    .frame(width: 80, height: 80)

                VStack(spacing: 12) {
                    Text(presentation.title)
                        .font(SiftFont.title)
                        .foregroundStyle(SiftColor.ink)
                        .multilineTextAlignment(.center)

                    Text(presentation.message)
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .multilineTextAlignment(.center)
                }

                switch presentation.progress {
                case .determinate(let progress):
                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(SiftColor.surfaceAlt)
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(SiftColor.accent)
                                    .frame(width: geo.size.width * progress, height: 4)
                            }
                        }
                        .frame(height: 4)
                        .frame(maxWidth: 220)

                        Text(String(format: "%.0f%%", progress * 100))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(SiftColor.quiet)
                    }
                case .indeterminate:
                    Text(presentation.status)
                        .font(SiftFont.caption)
                        .foregroundStyle(SiftColor.quiet)
                        .multilineTextAlignment(.center)
                }

                Text(presentation.note)
                    .font(SiftFont.caption)
                    .foregroundStyle(SiftColor.quiet)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, SiftSpace.gutter)
        }
    }

    private var readyView: some View {
        let isFirstRun = viewModel.lastTranscript.isEmpty
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(eyebrowDateString())
                    .font(SiftFont.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(SiftColor.quiet)
                    .textCase(.uppercase)
                    .padding(.bottom, 16)

                if isFirstRun {
                    Text(RecordingScreenOrientation.heading)
                        .font(SiftFont.display)
                        .foregroundStyle(SiftColor.ink)
                        .padding(.bottom, 16)

                    Text(RecordingScreenOrientation.reassurance)
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .lineSpacing(4)
                        .padding(.bottom, 8)

                    Text(RecordingScreenOrientation.nextStep)
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .lineSpacing(4)
                } else {
                    Group {
                        Text(RecordingScreenOrientation.returningHeading)
                            .font(SiftFont.display)
                            .foregroundStyle(SiftColor.ink)
                    }
                    .padding(.bottom, 16)

                    Text(RecordingScreenOrientation.returningGuidance)
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .lineSpacing(4)
                }

                Spacer().frame(height: SiftSpace.sectGap)

                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        recordButton
                        Text("Tap to begin")
                            .font(SiftFont.caption)
                            .foregroundStyle(SiftColor.muted)
                    }
                    Spacer()
                }

                if isFirstRun {
                    Spacer().frame(height: SiftSpace.sectGap)
                    starterPromptsView
                }

                Spacer().frame(height: 120)
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.top, 60)
        }
    }

    private var recordButton: some View {
        Button {
            viewModel.startRecording()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [SiftColor.accentSoft, SiftColor.bg],
                            center: .center,
                            startRadius: 39,
                            endRadius: 66
                        )
                    )
                    .frame(width: 132, height: 132)

                Circle()
                    .fill(SiftColor.accent)
                    .frame(width: 78, height: 78)
                    .shadow(color: SiftColor.accent.opacity(0.25), radius: 16, x: 0, y: 6)

                Image(systemName: "mic.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private var starterPromptsView: some View {
        VStack(alignment: .leading, spacing: SiftSpace.rowGap) {
            ForEach(RecordingScreenOrientation.starterPrompts, id: \.self) { prompt in
                Text(prompt)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.muted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: SiftRadius.pill)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                            .foregroundStyle(SiftColor.quiet)
                    )
            }
        }
    }

    private var recordingView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                Text("LISTENING")
                    .font(SiftFont.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(SiftColor.quiet)
                    .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text("I'm here.")
                        .font(SiftFont.display)
                        .foregroundStyle(SiftColor.ink)
                    Text("Take your time.")
                        .font(SiftFont.display)
                        .foregroundStyle(SiftColor.muted)
                }
                .lineSpacing(4)
                .padding(.bottom, SiftSpace.sectGap)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, SiftSpace.gutter)

            WaveformRibbon(height: 80)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, SiftSpace.gutter)
                .foregroundStyle(SiftColor.accent)
                .padding(.bottom, SiftSpace.sectGap)

            if !viewModel.lastTranscript.isEmpty {
                Text(viewModel.lastTranscript)
                    .font(SiftFont.body.italic())
                    .foregroundStyle(SiftColor.muted)
                    .lineLimit(2)
                    .padding(.horizontal, SiftSpace.gutter)
                    .padding(.bottom, SiftSpace.sectGap)
            }

            Spacer()

            VStack(spacing: 16) {
                Button {
                    viewModel.stopRecording()
                } label: {
                    Text("Stop")
                        .font(SiftFont.nameBold)
                        .foregroundStyle(SiftColor.accentInk)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(SiftColor.accentSoft)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Text("Reading on this phone only.")
                    .font(SiftFont.eyebrow)
                    .foregroundStyle(SiftColor.quiet)
            }
            .padding(.bottom, 48)
        }
    }

    private var preparingToRecordView: some View {
        VStack(spacing: 18) {
            BreathingDot()
                .frame(width: 80, height: 80)
            Text(RecordingScreenRecordingStartup.status)
                .font(SiftFont.body)
                .foregroundStyle(SiftColor.muted)
        }
        .padding()
    }

    private var transcribingView: some View {
        VStack(spacing: 16) {
            BreathingDot()
                .frame(width: 80, height: 80)
            Text("Transcribing...")
                .font(SiftFont.body)
                .foregroundStyle(SiftColor.muted)
        }
    }

    private func recoveryView(
        _ presentation: CheckInRecoveryPresentation,
        primaryOverride: (() -> Void)? = nil
    ) -> some View {
        let isMicDenied = presentation.kind == .microphonePermissionDenied
        return ScrollView {
            VStack(spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 60)

                ZStack {
                    Circle()
                        .fill(SiftColor.surface)
                        .frame(width: 72, height: 72)
                        .cardShadow()
                    Image(systemName: isMicDenied ? "mic.slash" : "exclamationmark.triangle")
                        .font(.system(size: 26))
                        .foregroundStyle(SiftColor.danger)
                }

                VStack(spacing: 10) {
                    Text(presentation.title)
                        .font(SiftFont.title)
                        .foregroundStyle(SiftColor.ink)
                        .multilineTextAlignment(.center)
                    Text(presentation.message)
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    Button(presentation.primaryActionLabel) {
                        if let primaryOverride {
                            primaryOverride()
                        } else {
                            handleRecoveryAction(presentation.primaryAction)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    if let secondaryLabel = presentation.secondaryActionLabel,
                       let secondaryAction = presentation.secondaryAction {
                        Button(secondaryLabel) {
                            handleRecoveryAction(secondaryAction)
                        }
                        .buttonStyle(GhostButtonStyle())
                    }
                }
            }
            .padding(.horizontal, SiftSpace.gutter)
        }
    }

    private func errorView(_ message: String, retry: @escaping () -> Void) -> some View {
        ScrollView {
            VStack(spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 60)
                ZStack {
                    Circle()
                        .fill(SiftColor.surface)
                        .frame(width: 72, height: 72)
                        .cardShadow()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 26))
                        .foregroundStyle(SiftColor.danger)
                }
                Text(message)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.muted)
                    .multilineTextAlignment(.center)
                Button("Retry") { retry() }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, SiftSpace.gutter)
        }
    }

    private func handleRecoveryAction(_ action: CheckInRecoveryPresentation.Action) {
        switch action {
        case .openSettings:
            if let url = RecordingScreenSettings.appSettingsURL {
                UIApplication.shared.open(url)
            }
        case .tryAgain:
            _ = viewModel.retryPermission()
        case .retryModelLoading:
            Task { await transcriptionService.loadModel() }
        case .retrySuggestions:
            viewModel.retryAnalysis()
        case .recordAgain:
            viewModel.recordAgain()
        case .trySavingAgain:
            viewModel.retrySave()
        }
    }

    private func eyebrowDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE · h:mm a"
        return formatter.string(from: Date())
    }
}
