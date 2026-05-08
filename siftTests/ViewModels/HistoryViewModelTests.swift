import Foundation
import Testing
@testable import sift

@MainActor
struct HistoryViewModelTests {

    @Test func deleteSessionsPassesSelectedSessionsToStore() {
        let store = FakeHistorySessionStore()
        let viewModel = HistoryViewModel()
        let first = Session(transcript: "first")
        let second = Session(transcript: "second")
        let third = Session(transcript: "third")
        viewModel.configure(sessionStore: store)

        viewModel.deleteSessions(at: IndexSet([0, 2]), from: [first, second, third])

        #expect(store.deletedSessions.count == 2)
        #expect(store.deletedSessions[0] === first)
        #expect(store.deletedSessions[1] === third)
        #expect(viewModel.deletionErrorMessage == nil)
    }

    @Test func deleteFailureSetsDeletionErrorMessage() {
        let store = FakeHistorySessionStore(deleteError: HistoryTestError.deleteFailed)
        let viewModel = HistoryViewModel()
        let session = Session(transcript: "delete me")
        viewModel.configure(sessionStore: store)

        viewModel.deleteSessions(at: IndexSet(integer: 0), from: [session])

        #expect(store.deletedSessions.isEmpty)
        #expect(viewModel.deletionErrorMessage?.contains("Deleting failed") == true)
        #expect(viewModel.deletionErrorMessage?.contains("delete failed") == true)
    }

    @Test func missingStoreSetsDeletionErrorMessage() {
        let viewModel = HistoryViewModel()

        viewModel.deleteSessions(at: IndexSet(integer: 0), from: [Session(transcript: "test")])

        #expect(viewModel.deletionErrorMessage == "Session store not configured")
    }

    @Test func clearDeletionErrorResetsErrorMessage() {
        let viewModel = HistoryViewModel()
        viewModel.deleteSessions(at: IndexSet(integer: 0), from: [Session(transcript: "test")])

        viewModel.clearDeletionError()

        #expect(viewModel.deletionErrorMessage == nil)
    }
}

private final class FakeHistorySessionStore: SessionStore {
    var deletedSessions: [Session] = []

    private let deleteError: Error?

    init(deleteError: Error? = nil) {
        self.deleteError = deleteError
    }

    func recommendationHistory() throws -> [SessionHistoryEntry] {
        []
    }

    func save(_ session: Session) throws {
    }

    func delete(_ sessions: [Session]) throws {
        if let deleteError { throw deleteError }
        deletedSessions.append(contentsOf: sessions)
    }
}

private enum HistoryTestError: LocalizedError {
    case deleteFailed

    var errorDescription: String? {
        "delete failed"
    }
}
