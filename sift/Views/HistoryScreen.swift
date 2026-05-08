import SwiftUI
import SwiftData

struct HistoryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Check-Ins Yet",
                        systemImage: "waveform",
                        description: Text("Record a voice check-in to receive practice suggestions.")
                    )
                } else {
                    List {
                        ForEach(sessions) { session in
                            NavigationLink {
                                SessionDetailView(session: session)
                            } label: {
                                sessionRow(session)
                            }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .navigationTitle("History")
            .onAppear {
                viewModel.configure(sessionStore: SwiftDataSessionStore(modelContext: modelContext))
            }
            .alert(
                "Couldn't Delete Check-In",
                isPresented: Binding(
                    get: { viewModel.deletionErrorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.clearDeletionError()
                        }
                    }
                )
            ) {
                Button("OK") {
                    viewModel.clearDeletionError()
                }
            } message: {
                Text(viewModel.deletionErrorMessage ?? "")
            }
        }
    }

    private func sessionRow(_ session: Session) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.timestamp, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(session.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !session.attempts.isEmpty {
                    Text(summary(for: session.attempts))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(session.transcript)
                .font(.body)
                .lineLimit(2)

            HStack(spacing: 16) {
                Label("\(Int(session.audioDuration))s", systemImage: "mic")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !session.attempts.isEmpty {
                    Label("\(session.attempts.count) practices", systemImage: "figure.mind.and.body")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func summary(for attempts: [PracticeAttempt]) -> String {
        let helpful = attempts.filter { $0.wasHelpful == true }.count
        let notHelpful = attempts.filter { $0.wasHelpful == false }.count
        var parts: [String] = []
        if helpful > 0 { parts.append("\(helpful) helpful") }
        if notHelpful > 0 { parts.append("\(notHelpful) not") }
        return parts.joined(separator: ", ")
    }

    private func deleteSessions(at offsets: IndexSet) {
        viewModel.deleteSessions(at: offsets, from: sessions)
    }
}
