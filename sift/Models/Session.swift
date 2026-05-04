import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID
    var timestamp: Date
    var transcript: String
    var audioDuration: TimeInterval
    var transcriptionDurationMs: Int

    @Relationship(deleteRule: .cascade, inverse: \PracticeAttempt.session)
    var attempts: [PracticeAttempt] = []

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        transcript: String = "",
        audioDuration: TimeInterval = 0,
        transcriptionDurationMs: Int = 0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.transcript = transcript
        self.audioDuration = audioDuration
        self.transcriptionDurationMs = transcriptionDurationMs
    }
}
