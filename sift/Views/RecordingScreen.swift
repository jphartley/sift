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
        NavigationStack {
            Group {
                switch transcriptionService.modelState {
                case .downloading, .loading, .notLoaded:
                    loadingView
                case .failed:
                    recoveryView(.modelLoadingFailed) {
                        Task {
                            await transcriptionService.loadModel()
                        }
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
                        errorView(message) {
                            viewModel.retryAnalysis()
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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

    private var loadingView: some View {
        let presentation = RecordingScreenSetup.presentation(for: transcriptionService.modelState)

        return VStack(spacing: 18) {
            VStack(spacing: 8) {
                Text(presentation.title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(presentation.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            switch presentation.progress {
            case .determinate(let progress):
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .frame(maxWidth: 220)
            case .indeterminate:
                ProgressView()
                    .scaleEffect(1.2)
            }

            Text(presentation.status)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(presentation.note)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    private var readyView: some View {
        ScrollView {
            VStack(spacing: 28) {
                if viewModel.lastTranscript.isEmpty {
                    orientationView
                } else {
                    returningOrientationView
                }

                if !viewModel.lastTranscript.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Transcript")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(viewModel.lastTranscript)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Button {
                    viewModel.startRecording()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 88, height: 88)
                        Image(systemName: "mic.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)

                Text("Tap to record")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if viewModel.lastTranscript.isEmpty {
                    starterPromptsView
                }

                if !viewModel.lastTranscript.isEmpty {
                    Text("Swipe to History tab to review past check-ins")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }

    private var returningOrientationView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(RecordingScreenOrientation.returningHeading)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(RecordingScreenOrientation.returningGuidance)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var orientationView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(RecordingScreenOrientation.heading)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(RecordingScreenOrientation.reassurance)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(RecordingScreenOrientation.nextStep)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var starterPromptsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(RecordingScreenOrientation.starterHeading)
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(RecordingScreenOrientation.starterPrompts, id: \.self) { prompt in
                Text(prompt)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recordingView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                    Text("Recording")
                        .font(.headline)
                        .foregroundStyle(.red)
                }

                Text(formatDuration(viewModel.recordingDuration))
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
            }

            HStack(spacing: 2) {
                ForEach(0..<30, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.red.opacity(barOpacity(for: i)))
                        .frame(width: 3, height: barHeight(for: i))
                }
            }
            .frame(height: 40)

            Button {
                viewModel.stopRecording()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.red)
                        .frame(width: 60, height: 60)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: 20, height: 20)
                }
            }
            .buttonStyle(.plain)

            Text("Tap to stop")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private var preparingToRecordView: some View {
        VStack(spacing: 18) {
            ProgressView()
                .scaleEffect(1.2)

            Text(RecordingScreenRecordingStartup.status)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func barOpacity(for index: Int) -> Double {
        let normalizedLevel = Double(viewModel.audioLevel + 60) / 60.0
        let clamped = min(max(normalizedLevel, 0.0), 1.0)
        let threshold = Double(index) / 30.0
        return clamped > (1.0 - threshold) ? 1.0 : 0.2
    }

    private func barHeight(for index: Int) -> CGFloat {
        let base: CGFloat = 8
        let normalizedLevel = Double(viewModel.audioLevel + 60) / 60.0
        let clamped = min(max(normalizedLevel, 0.0), 1.0)
        let threshold = Double(index) / 30.0
        return clamped > (1.0 - threshold) ? base + CGFloat(clamped * 28.0) : base
    }

    private var transcribingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Transcribing...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func recoveryView(
        _ presentation: CheckInRecoveryPresentation,
        primaryOverride: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 38))
                .foregroundStyle(.blue)

            VStack(spacing: 8) {
                Text(presentation.title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(presentation.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(presentation.primaryActionLabel) {
                if let primaryOverride {
                    primaryOverride()
                } else {
                    handleRecoveryAction(presentation.primaryAction)
                }
            }
            .buttonStyle(.borderedProminent)

            if let secondaryActionLabel = presentation.secondaryActionLabel,
               let secondaryAction = presentation.secondaryAction {
                Button(secondaryActionLabel) {
                    handleRecoveryAction(secondaryAction)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    private func errorView(_ message: String, retry: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.blue)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                retry()
            }
            .buttonStyle(.borderedProminent)
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
            Task {
                await transcriptionService.loadModel()
            }
        case .retrySuggestions:
            viewModel.retryAnalysis()
        case .recordAgain:
            viewModel.recordAgain()
        case .trySavingAgain:
            viewModel.retrySave()
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let seconds = Int(duration)
        let tenths = Int((duration - Double(seconds)) * 10)
        return String(format: "%d.%ds", seconds, tenths)
    }
}
