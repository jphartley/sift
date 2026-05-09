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
    private static let recommendationHistoryLimit = 20
    private static let recentRecommendationHistoryLimit = 10
    private static let helpfulRecommendationHistoryLimit = 10

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recommendationHistory() throws -> [SessionHistoryEntry] {
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        let sessions = try modelContext.fetch(descriptor)
        let selectedSessions = selectRecommendationHistory(from: sessions)

        return selectedSessions.map { session in
            let attempt = session.attempts.first
            return SessionHistoryEntry(
                timestamp: session.timestamp,
                transcript: session.transcript,
                practiceName: attempt?.practiceName,
                wasHelpful: attempt?.wasHelpful
            )
        }
    }

    private func selectRecommendationHistory(from sessions: [Session]) -> [Session] {
        if sessions.count <= Self.recommendationHistoryLimit {
            return sessions
        }

        let recent = Array(sessions.prefix(Self.recentRecommendationHistoryLimit))
        let recentIDs = Set(recent.map(\.id))
        let helpful = sessions
            .filter { session in
                !recentIDs.contains(session.id) && session.attempts.contains { $0.wasHelpful == true }
            }
            .prefix(Self.helpfulRecommendationHistoryLimit)

        var seenIDs: Set<UUID> = []
        return (recent + helpful)
            .filter { session in
                seenIDs.insert(session.id).inserted
            }
            .sorted { $0.timestamp > $1.timestamp }
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
