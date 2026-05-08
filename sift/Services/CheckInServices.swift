import Foundation
import SwiftData

protocol AudioRecording: AnyObject {
    var isRecording: Bool { get }
    var recordingDuration: TimeInterval { get }
    var audioLevel: Float { get }

    func requestPermission() async -> Bool
    func startRecording() throws -> URL
    func stopRecording()
}

protocol TranscriptionClient: AnyObject {
    var modelState: ModelState { get }

    func transcribe(audioURL: URL) async throws -> (text: String, durationMs: Int)
}

protocol RecommendationClient: AnyObject {
    func recommend(transcript: String, history: [SessionHistoryEntry]) async throws -> RecommendationResult
}

protocol SessionStore: AnyObject {
    func recommendationHistory() throws -> [SessionHistoryEntry]
    func save(_ session: Session) throws
    func delete(_ sessions: [Session]) throws
}

final class SwiftDataSessionStore: SessionStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recommendationHistory() throws -> [SessionHistoryEntry] {
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        let sessions = try modelContext.fetch(descriptor)

        return sessions.map { session in
            let attempt = session.attempts.first
            return SessionHistoryEntry(
                timestamp: session.timestamp,
                transcript: session.transcript,
                practiceName: attempt?.practiceName,
                wasHelpful: attempt?.wasHelpful
            )
        }
    }

    func save(_ session: Session) throws {
        modelContext.insert(session)
        try modelContext.save()
    }

    func delete(_ sessions: [Session]) throws {
        for session in sessions {
            modelContext.delete(session)
        }
        try modelContext.save()
    }
}
