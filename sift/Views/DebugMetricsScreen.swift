#if DEBUG
import SwiftUI
import SwiftData

struct DebugMetricsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MetricEvent.timestamp, order: .reverse) private var events: [MetricEvent]
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Metrics")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear all", role: .destructive) {
                            showClearConfirmation = true
                        }
                        .disabled(events.isEmpty)
                    }
                }
                .confirmationDialog(
                    "Clear all recorded metrics?",
                    isPresented: $showClearConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Clear all", role: .destructive) {
                        clearAllMetrics()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This deletes every MetricEvent. Sessions and practices are not affected.")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if events.isEmpty {
            emptyState
        } else {
            summaryList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("No metrics recorded yet")
                .font(.headline)
            Text("Use the app — record a check-in, run analysis — and metric events will appear here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var summaryList: some View {
        List {
            Section {
                EscalationPill(events: events)
            }
            Section("Per-metric") {
                ForEach(metricSummaries, id: \.name) { summary in
                    NavigationLink(value: summary.name) {
                        MetricSummaryRow(summary: summary)
                    }
                }
            }
        }
        .navigationDestination(for: String.self) { name in
            MetricDetailView(metricName: name)
        }
    }

    private var metricSummaries: [MetricSummary] {
        let grouped = Dictionary(grouping: events, by: \.name)
        return grouped
            .map { name, events in
                MetricSummary(name: name, events: events)
            }
            .sorted { $0.name < $1.name }
    }

    private func clearAllMetrics() {
        for event in events {
            modelContext.delete(event)
        }
        try? modelContext.save()
    }
}

struct MetricSummary {
    let name: String
    let count: Int
    let p50: Int
    let p95: Int
    let last: Int

    init(name: String, events: [MetricEvent]) {
        self.name = name
        self.count = events.count
        let durations = events.map(\.durationMs).sorted()
        self.p50 = MetricStats.percentile(durations, percentile: 0.5)
        self.p95 = MetricStats.percentile(durations, percentile: 0.95)
        let mostRecent = events.max(by: { $0.timestamp < $1.timestamp })
        self.last = mostRecent?.durationMs ?? 0
    }
}

enum MetricStats {
    static func percentile(_ sortedDurations: [Int], percentile: Double) -> Int {
        guard !sortedDurations.isEmpty else { return 0 }
        if sortedDurations.count == 1 { return sortedDurations[0] }
        let position = Double(sortedDurations.count - 1) * percentile
        let lowerIndex = Int(position.rounded(.down))
        let upperIndex = Int(position.rounded(.up))
        if lowerIndex == upperIndex { return sortedDurations[lowerIndex] }
        let lower = Double(sortedDurations[lowerIndex])
        let upper = Double(sortedDurations[upperIndex])
        let fraction = position - Double(lowerIndex)
        return Int((lower + (upper - lower) * fraction).rounded())
    }
}

struct MetricSummaryRow: View {
    let summary: MetricSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(summary.name)
                .font(.system(.body, design: .monospaced))
            HStack(spacing: 12) {
                Label("\(summary.count)", systemImage: "number")
                Label("p50 \(summary.p50)ms", systemImage: "circle.lefthalf.filled")
                Label("p95 \(summary.p95)ms", systemImage: "circle.righthalf.filled")
                Label("last \(summary.last)ms", systemImage: "clock")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .labelStyle(.titleOnly)
        }
        .padding(.vertical, 2)
    }
}

struct EscalationPill: View {
    let events: [MetricEvent]

    private var flashCount: Int {
        events.filter { $0.name == "gemini.flash" }.count
    }
    private var proCount: Int {
        events.filter { $0.name == "gemini.pro" }.count
    }

    var body: some View {
        HStack {
            Text("Escalations")
                .font(.subheadline.weight(.medium))
            Spacer()
            if flashCount == 0 {
                Text("no data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                let pct = Int((Double(proCount) / Double(flashCount) * 100).rounded())
                Text("\(proCount) / \(flashCount) (\(pct)%)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(pct >= 30 ? .red : .secondary)
            }
        }
    }
}

struct MetricDetailView: View {
    let metricName: String
    @Query private var events: [MetricEvent]

    init(metricName: String) {
        self.metricName = metricName
        let predicate = #Predicate<MetricEvent> { $0.name == metricName }
        _events = Query(filter: predicate, sort: \MetricEvent.timestamp, order: .reverse)
    }

    private var p95Threshold: Int {
        let sorted = events.map(\.durationMs).sorted()
        return MetricStats.percentile(sorted, percentile: 0.95)
    }

    var body: some View {
        List {
            ForEach(events) { event in
                EventRow(event: event, p95Threshold: p95Threshold)
            }
        }
        .navigationTitle(metricName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EventRow: View {
    let event: MetricEvent
    let p95Threshold: Int

    private var isOutlier: Bool {
        event.durationMs > p95Threshold && p95Threshold > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(event.durationMs)ms")
                    .font(.body.monospacedDigit())
                    .foregroundStyle(isOutlier ? .red : .primary)
                if isOutlier {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                Spacer()
                Text(event.timestamp.formatted(date: .abbreviated, time: .standard))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            if let metadata = event.metadataJSON {
                Text(metadata)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}
#endif
