import Foundation

@Observable
final class HistoryViewModel {
    var deletionErrorMessage: String?

    private var sessionStore: SessionStore?

    func configure(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    func deleteSessions(at offsets: IndexSet, from sessions: [Session]) {
        guard let sessionStore else {
            deletionErrorMessage = "Session store not configured"
            return
        }

        let sessionsToDelete = offsets.map { sessions[$0] }

        do {
            try sessionStore.delete(sessionsToDelete)
            deletionErrorMessage = nil
        } catch {
            deletionErrorMessage = "Deleting failed: \(error.localizedDescription)"
        }
    }

    func clearDeletionError() {
        deletionErrorMessage = nil
    }
}
