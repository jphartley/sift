import Foundation
import SwiftData

@Model
final class PracticeAttempt {
    var id: UUID
    var practiceID: String
    var practiceName: String
    var timestamp: Date
    var completed: Bool
    var wasHelpful: Bool?
    var notes: String?

    var session: Session?

    init(
        id: UUID = UUID(),
        practiceID: String = "",
        practiceName: String = "",
        timestamp: Date = Date(),
        completed: Bool = true,
        wasHelpful: Bool? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.practiceID = practiceID
        self.practiceName = practiceName
        self.timestamp = timestamp
        self.completed = completed
        self.wasHelpful = wasHelpful
        self.notes = notes
    }
}
