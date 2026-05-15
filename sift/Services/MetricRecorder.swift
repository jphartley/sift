import Foundation
import SwiftData

@Observable
final class MetricRecorder {
    private let modelContext: ModelContext?
    private let printer: (String) -> Void

    init(modelContext: ModelContext?, printer: @escaping (String) -> Void = { print($0) }) {
        self.modelContext = modelContext
        self.printer = printer
    }

    func record(name: String, durationMs: Int, metadata: [String: String]? = nil) {
        let metadataJSON = encode(metadata)
        printer(formatLine(name: name, durationMs: durationMs, metadataJSON: metadataJSON))

        guard let modelContext else { return }
        let event = MetricEvent(name: name, durationMs: durationMs, metadataJSON: metadataJSON)
        modelContext.insert(event)
        do {
            try modelContext.save()
        } catch {
            printer("[MetricRecorder] Persistence failed for \(name): \(error.localizedDescription)")
        }
    }

    @discardableResult
    func time<T>(name: String, metadata: [String: String]? = nil, _ block: () async throws -> T) async rethrows -> T {
        let start = Date()
        let result = try await block()
        let durationMs = Int(Date().timeIntervalSince(start) * 1000)
        record(name: name, durationMs: durationMs, metadata: metadata)
        return result
    }

    @discardableResult
    func timeSync<T>(name: String, metadata: [String: String]? = nil, _ block: () throws -> T) rethrows -> T {
        let start = Date()
        let result = try block()
        let durationMs = Int(Date().timeIntervalSince(start) * 1000)
        record(name: name, durationMs: durationMs, metadata: metadata)
        return result
    }

    private func encode(_ metadata: [String: String]?) -> String? {
        guard let metadata, !metadata.isEmpty else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: metadata, options: [.sortedKeys]) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private func formatLine(name: String, durationMs: Int, metadataJSON: String?) -> String {
        let metaSegment = metadataJSON.map { " meta=\($0)" } ?? ""
        return "METRIC name=\(name) ms=\(durationMs)\(metaSegment)"
    }
}
