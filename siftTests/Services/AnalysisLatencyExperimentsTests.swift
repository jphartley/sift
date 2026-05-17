import Foundation
import Testing
@testable import sift

struct AnalysisLatencyExperimentsTests {
    @Test func snapshotBaselineHasNoLabels() {
        let snapshot = AnalysisLatencyExperimentSnapshot.baseline

        #expect(snapshot.activeLabels.isEmpty)
        #expect(snapshot.metricMetadata.isEmpty)
    }

    @Test func snapshotLabelsReflectEnabledExperiments() {
        var snapshot = AnalysisLatencyExperimentSnapshot.baseline
        snapshot.flashModelVariant = .stable
        snapshot.responseSchemaMode = .relaxed
        snapshot.promptContextTrimmingEnabled = true
        snapshot.outputTokenBudget = .reduced
        snapshot.confidenceThreshold = .reduced
        snapshot.escalationDisabled = true

        #expect(snapshot.activeLabels == [
            "flash=2.5-stable",
            "schema=relaxed",
            "prompt=trimmed",
            "output=1024",
            "threshold=0.5",
            "escalation=off"
        ])
        #expect(snapshot.metricMetadata["analysis.experiments"] == "flash=2.5-stable|schema=relaxed|prompt=trimmed|output=1024|threshold=0.5|escalation=off")
    }

    @Test func generationProfileReflectsSchemaAndBudget() {
        var snapshot = AnalysisLatencyExperimentSnapshot.baseline
        snapshot.responseSchemaMode = .relaxed
        snapshot.outputTokenBudget = .reduced

        #expect(snapshot.generationProfile.maxOutputTokens == 1024)
        #expect(snapshot.generationProfile.responseSchemaIsStrict == false)
        #expect(snapshot.generationProfile.responseMIMEType == nil)
    }

    @Test func metricEventParsesExperimentLabelsFromMetadata() {
        let event = MetricEvent(
            name: "gemini.total",
            durationMs: 123,
            metadataJSON: #"{"analysis.experiments":"flash=2.5-stable|schema=relaxed"}"#
        )

        #expect(event.analysisLatencyExperimentLabels == ["flash=2.5-stable", "schema=relaxed"])
    }
}
