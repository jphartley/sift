import SwiftUI
import SwiftData

enum AppStoragePreparation {
    static func prepareApplicationSupportDirectory() throws {
        _ = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
}

@main
struct siftApp: App {
    let container: ModelContainer
    let metricRecorder: MetricRecorder
    let experimentStore: AnalysisLatencyExperimentStore
    @State private var transcriptionService: TranscriptionService
    @State private var geminiService: GeminiService
    @State private var audioRecorderService: AudioRecorderService

    init() {
        let resolvedContainer: ModelContainer
        do {
            try AppStoragePreparation.prepareApplicationSupportDirectory()
            resolvedContainer = try ModelContainer(for: Session.self, PracticeAttempt.self, MetricEvent.self, UserPracticeProfile.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        self.container = resolvedContainer
        let recorder = MetricRecorder(modelContext: ModelContext(resolvedContainer))
        let experiments = AnalysisLatencyExperimentStore()
        self.metricRecorder = recorder
        self.experimentStore = experiments
        recorder.timeSync(name: "practiceLibrary.load") {
            _ = Practice.all
        }
        _transcriptionService = State(initialValue: TranscriptionService(recorder: recorder))
        _geminiService = State(initialValue: GeminiService(recorder: recorder, experimentStore: experiments))
        _audioRecorderService = State(initialValue: AudioRecorderService(metricRecorder: recorder))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await transcriptionService.loadModel()
                }
                .environment(transcriptionService)
                .environment(geminiService)
                .environment(audioRecorderService)
                .environment(metricRecorder)
                .environment(experimentStore)
        }
        .modelContainer(container)
    }
}
