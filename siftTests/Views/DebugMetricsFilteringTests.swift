import Foundation
import Testing
@testable import sift

struct DebugMetricsFilteringTests {
    @Test func availableLabelsAreSortedAndUnique() {
        let events = [
            MetricEvent(name: "a", durationMs: 1, metadataJSON: #"{"analysis.experiments":"output=1024|flash=2.5-stable"}"#),
            MetricEvent(name: "b", durationMs: 2, metadataJSON: #"{"analysis.experiments":"flash=2.5-stable|schema=relaxed"}"#)
        ]

        #expect(DebugMetricsFiltering.availableExperimentLabels(from: events) == [
            "flash=2.5-stable",
            "output=1024",
            "schema=relaxed"
        ])
    }

    @Test func filteredEventsMatchLabel() {
        let matching = MetricEvent(name: "a", durationMs: 1, metadataJSON: #"{"analysis.experiments":"flash=2.5-stable|schema=relaxed"}"#)
        let other = MetricEvent(name: "b", durationMs: 2, metadataJSON: #"{"analysis.experiments":"output=1024"}"#)

        let filtered = DebugMetricsFiltering.filteredEvents([matching, other], by: "flash=2.5-stable")

        #expect(filtered.map(\.name) == ["a"])
    }

    @Test func allFilterReturnsEveryEvent() {
        let events = [
            MetricEvent(name: "a", durationMs: 1),
            MetricEvent(name: "b", durationMs: 2)
        ]

        #expect(DebugMetricsFiltering.filteredEvents(events, by: "All").map(\.name) == ["a", "b"])
    }

    @Test func unavailableFilterSelectionFallsBackToAll() {
        let selection = DebugMetricsFiltering.normalizedSelection(
            "flash=2.5-stable",
            availableLabels: ["schema=relaxed"]
        )

        #expect(selection == DebugMetricsFiltering.allLabel)
    }

    @Test func availableFilterSelectionIsPreserved() {
        let selection = DebugMetricsFiltering.normalizedSelection(
            "flash=2.5-stable",
            availableLabels: ["flash=2.5-stable"]
        )

        #expect(selection == "flash=2.5-stable")
    }

    @Test func experimentStatusSummarizesBaselineAndActiveExperiments() {
        #expect(DebugExperimentPresentation.statusText(for: []) == "Baseline")
        #expect(DebugExperimentPresentation.statusText(for: ["flash=2.5-stable"]) == "1 active")
        #expect(DebugExperimentPresentation.statusText(for: ["flash=2.5-stable", "schema=relaxed"]) == "2 active")
    }
}
