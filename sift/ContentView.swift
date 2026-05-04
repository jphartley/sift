import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            RecordingScreen()
                .tabItem {
                    Label("Record", systemImage: "mic.fill")
                }

            HistoryScreen()
                .tabItem {
                    Label("History", systemImage: "list.bullet.rectangle")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
}
