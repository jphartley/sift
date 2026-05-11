import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: SiftTab = .today

    var body: some View {
        Group {
            switch selectedTab {
            case .today:
                RecordingScreen()
            case .history:
                HistoryScreen()
            case .privacy:
                PrivacyScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SiftTabBar(selected: $selectedTab)
        }
        .background(SiftColor.bg.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
}
