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
    @State private var transcriptionService = TranscriptionService()
    @State private var geminiService = GeminiService()

    init() {
        do {
            try AppStoragePreparation.prepareApplicationSupportDirectory()
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
