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

extension MetricEvent {
    var metadataDictionary: [String: String] {
        guard
            let metadataJSON,
            let data = metadataJSON.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data),
            let dictionary = object as? [String: String]
        else {
            return [:]
        }
        return dictionary
    }

    var analysisLatencyExperimentLabels: [String] {
        guard let value = metadataDictionary["analysis.experiments"], !value.isEmpty else {
            return []
        }
        return value.split(separator: "|").map(String.init)
    }
}
