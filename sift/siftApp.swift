import SwiftUI
import SwiftData

@main
struct siftApp: App {
    let container: ModelContainer
    @State private var transcriptionService = TranscriptionService()
    @State private var geminiService = GeminiService()

    init() {
        do {
            container = try ModelContainer(for: Session.self, PracticeAttempt.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await transcriptionService.loadModel()
                }
                .environment(transcriptionService)
                .environment(geminiService)
        }
        .modelContainer(container)
    }
}
