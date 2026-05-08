import SwiftUI
import SwiftData

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
                case .failed(let message):
                    errorView(message) {
                        Task {
                            await transcriptionService.loadModel()
                        }
                    }
                case .ready:
                    switch viewModel.state {
                    case .idle, .loadingModel, .ready:
                        readyView
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
                    case .error(let message):
                        errorView(message) {
                            viewModel.retryAnalysis()
                        }
                    }
                }
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
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
        VStack(spacing: 16) {
            if case .downloading(let progress) = transcriptionService.modelState {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .frame(width: 200)
                Text("Downloading speech model...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Preparing speech model...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var readyView: some View {
        VStack(spacing: 32) {
            Spacer()

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
                .padding(.horizontal)
            }

            Button {
                viewModel.startRecording()
            } label: {
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 80, height: 80)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Text("Tap to record")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            if !viewModel.lastTranscript.isEmpty {
                Text("Swipe to History tab to review past check-ins")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom)
            }
        }
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

    private func errorView(_ message: String, retry: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
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

    private func formatDuration(_ duration: TimeInterval) -> String {
        let seconds = Int(duration)
        let tenths = Int((duration - Double(seconds)) * 10)
        return String(format: "%d.%ds", seconds, tenths)
    }
}
