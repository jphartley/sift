import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: SiftTab = .today
    @Query(sort: \UserPracticeProfile.updatedAt, order: .reverse) private var profiles: [UserPracticeProfile]

    var body: some View {
        Group {
            switch selectedTab {
            case .today:
                if IntakeGate.shouldShowIntake(profiles: profiles) {
                    IntakeScreen()
                } else {
                    RecordingScreen()
                }
            case .history:
                HistoryScreen()
            case .privacy:
                PrivacyScreen()
            #if DEBUG
            case .debug:
                DebugMetricsScreen()
            #endif
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SiftTabBar(selected: $selectedTab)
        }
        .background(SiftColor.bg.ignoresSafeArea())
    }
}

enum IntakeGate {
    static func shouldShowIntake(profiles: [UserPracticeProfile]) -> Bool {
        profiles.isEmpty
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Session.self, PracticeAttempt.self, MetricEvent.self, UserPracticeProfile.self], inMemory: true)
}
