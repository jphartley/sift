import SwiftUI
import SwiftData

enum HistoryRowPresentation {
    static func pillText(for attempt: PracticeAttempt) -> String {
        attempt.practiceName
    }
}

struct HistoryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @State private var viewModel = HistoryViewModel()

    private var grouped: [(label: String, sessions: [Session])] {
        let calendar = Calendar.current
        let now = Date()
        let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfThisWeek) ?? now

        var thisWeek: [Session] = []
        var lastWeek: [Session] = []
        var earlier:  [Session] = []

        for session in sessions {
            if session.timestamp >= startOfThisWeek {
                thisWeek.append(session)
            } else if session.timestamp >= startOfLastWeek {
                lastWeek.append(session)
            } else {
                earlier.append(session)
            }
        }

        var groups: [(label: String, sessions: [Session])] = []
        if !thisWeek.isEmpty  { groups.append((label: "This week",  sessions: thisWeek)) }
        if !lastWeek.isEmpty  { groups.append((label: "Last week",  sessions: lastWeek)) }
        if !earlier.isEmpty   { groups.append((label: "Earlier",    sessions: earlier))  }
        return groups
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                headerSection

                if sessions.isEmpty {
                    emptyState
                } else {
                    ForEach(grouped, id: \.label) { group in
                        sessionGroup(group)
                    }
                    Spacer().frame(height: 80)
                }
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.top, 60)
        }
        .background(SiftColor.bg.ignoresSafeArea())
        .onAppear {
            viewModel.configure(sessionStore: SwiftDataSessionStore(modelContext: modelContext))
        }
        .alert(
            "Couldn't Delete Check-In",
            isPresented: Binding(
                get: { viewModel.deletionErrorMessage != nil },
                set: { isPresented in
                    if !isPresented { viewModel.clearDeletionError() }
                }
            )
        ) {
            Button("OK") { viewModel.clearDeletionError() }
        } message: {
            Text(viewModel.deletionErrorMessage ?? "")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("History")
                .font(SiftFont.display)
                .foregroundStyle(SiftColor.ink)

            let caption = sessions.isEmpty
                ? "A quiet record of your check-ins."
                : "\(sessions.count) check-in\(sessions.count == 1 ? "" : "s") so far."

            Text(caption)
                .font(SiftFont.caption)
                .foregroundStyle(SiftColor.quiet)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: SiftRadius.card)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(SiftColor.quiet)
                    .frame(height: 160)

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(SiftColor.surfaceAlt)
                            .frame(width: 56, height: 56)
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 22))
                            .foregroundStyle(SiftColor.quiet)
                    }

                    VStack(spacing: 6) {
                        Text("Nothing here yet")
                            .font(SiftFont.heading)
                            .foregroundStyle(SiftColor.ink)
                        Text("Record a voice check-in to receive practice suggestions.")
                            .font(SiftFont.body)
                            .foregroundStyle(SiftColor.muted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private func sessionGroup(_ group: (label: String, sessions: [Session])) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.label.uppercased())
                .font(SiftFont.eyebrow)
                .tracking(1.2)
                .foregroundStyle(SiftColor.quiet)

            VStack(spacing: 0) {
                ForEach(Array(group.sessions.enumerated()), id: \.element.id) { idx, session in
                    VStack(spacing: 0) {
                        if idx > 0 {
                            Divider().background(SiftColor.line)
                        }
                        sessionRow(session)
                    }
                }
            }
            .background(SiftColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: SiftRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: SiftRadius.card)
                    .strokeBorder(SiftColor.line, lineWidth: 1)
            )
            .cardShadow()
        }
    }

    private func sessionRow(_ session: Session) -> some View {
        NavigationLink {
            SessionDetailView(session: session)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayAbbrev(session.timestamp))
                        .font(SiftFont.body.weight(.semibold))
                        .foregroundStyle(SiftColor.ink)
                    Text(timeString(session.timestamp))
                        .font(SiftFont.caption)
                        .foregroundStyle(SiftColor.quiet)
                }
                .frame(width: 36, alignment: .leading)

                VStack(alignment: .leading, spacing: 6) {
                    Text(session.transcript)
                        .font(SiftFont.body.italic())
                        .foregroundStyle(SiftColor.ink)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        if let attempt = session.attempts.first {
                            PillTag(text: HistoryRowPresentation.pillText(for: attempt), tone: .soft)
                            Text(helpfulnessCaption(attempt))
                                .font(SiftFont.caption)
                                .foregroundStyle(helpfulnessColor(attempt))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, SiftSpace.cardPad)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
                    viewModel.deleteSessions(at: IndexSet([idx]), from: sessions)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func helpfulnessCaption(_ attempt: PracticeAttempt) -> String {
        switch attempt.wasHelpful {
        case true:  return "· Helped"
        case false: return "· Not really"
        default:    return "· —"
        }
    }

    private func helpfulnessColor(_ attempt: PracticeAttempt) -> Color {
        switch attempt.wasHelpful {
        case true:  return SiftColor.helpful
        case false: return SiftColor.muted
        default:    return SiftColor.quiet
        }
    }
}
