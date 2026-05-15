import Foundation
import SwiftData
import Testing
@testable import sift

@MainActor
struct MetricRecorderTests {
    @Test func recordPersistsEventToSwiftData() throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        let recorder = MetricRecorder(modelContext: context, printer: { _ in })

        recorder.record(name: "test.metric", durationMs: 42)

        let events = try context.fetch(FetchDescriptor<MetricEvent>())
        #expect(events.count == 1)
        #expect(events.first?.name == "test.metric")
        #expect(events.first?.durationMs == 42)
        #expect(events.first?.metadataJSON == nil)
    }

    @Test func recordEmitsStableConsoleLine() throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        var lines: [String] = []
        let recorder = MetricRecorder(modelContext: context, printer: { lines.append($0) })

        recorder.record(name: "gemini.flash", durationMs: 1234)

        #expect(lines.count == 1)
        #expect(lines.first == "METRIC name=gemini.flash ms=1234")
    }

    @Test func recordRoundTripsMetadataAsJSON() throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        var lines: [String] = []
        let recorder = MetricRecorder(modelContext: context, printer: { lines.append($0) })

        recorder.record(name: "whisper.download", durationMs: 8000, metadata: ["variant": "openai_whisper-base.en"])

        let events = try context.fetch(FetchDescriptor<MetricEvent>())
        #expect(events.first?.metadataJSON == #"{"variant":"openai_whisper-base.en"}"#)
        #expect(lines.first == #"METRIC name=whisper.download ms=8000 meta={"variant":"openai_whisper-base.en"}"#)
    }

    @Test func consoleLineEmitsEvenWithNilContext() throws {
        var lines: [String] = []
        let recorder = MetricRecorder(modelContext: nil, printer: { lines.append($0) })

        recorder.record(name: "no.context", durationMs: 5)

        #expect(lines.count == 1)
        #expect(lines.first == "METRIC name=no.context ms=5")
    }

    @Test func timeMeasuresAsyncBlockAndRecords() async throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        let recorder = MetricRecorder(modelContext: context, printer: { _ in })

        let result = try await recorder.time(name: "async.work") {
            try await Task.sleep(for: .milliseconds(20))
            return "done"
        }

        #expect(result == "done")
        let events = try context.fetch(FetchDescriptor<MetricEvent>())
        #expect(events.count == 1)
        #expect(events.first?.name == "async.work")
        #expect((events.first?.durationMs ?? 0) >= 15)
    }

    @Test func timeSyncMeasuresSyncBlockAndRecords() throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        let recorder = MetricRecorder(modelContext: context, printer: { _ in })

        let value = recorder.timeSync(name: "sync.work") { 7 }

        #expect(value == 7)
        let events = try context.fetch(FetchDescriptor<MetricEvent>())
        #expect(events.first?.name == "sync.work")
    }
}
