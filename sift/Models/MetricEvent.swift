import Foundation
import SwiftData

@Model
final class MetricEvent {
    var name: String
    var durationMs: Int
    var timestamp: Date
    var metadataJSON: String?

    init(name: String, durationMs: Int, timestamp: Date = Date(), metadataJSON: String? = nil) {
        self.name = name
        self.durationMs = durationMs
        self.timestamp = timestamp
        self.metadataJSON = metadataJSON
    }
}
