import SwiftUI
import SwiftData

@main
struct siftApp: App {
    let container: ModelContainer

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
        }
        .modelContainer(container)
    }
}
