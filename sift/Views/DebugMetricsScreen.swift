#if DEBUG
import SwiftUI
import SwiftData

enum DebugMetricsFiltering {
    static let allLabel = "All"

    static func filteredEvents(_ events: [MetricEvent], by experimentLabel: String) -> [MetricEvent] {
        guard experimentLabel != allLabel else { return events }
        return events.filter { $0.analysisLatencyExperimentLabels.contains(experimentLabel) }
    }

    static func availableExperimentLabels(from events: [MetricEvent]) -> [String] {
        Array(Set(events.flatMap(\.analysisLatencyExperimentLabels))).sorted()
    }

    static func normalizedSelection(_ selection: String, availableLabels: [String]) -> String {
        selection == allLabel || availableLabels.contains(selection) ? selection : allLabel
    }
}

enum DebugExperimentPresentation {
    static func statusText(for activeLabels: [String]) -> String {
        activeLabels.isEmpty ? "Baseline" : "\(activeLabels.count) active"
    }
}

struct DebugMetricsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AnalysisLatencyExperimentStore.self) private var experimentStore
    @Query(sort: \MetricEvent.timestamp, order: .reverse) private var events: [MetricEvent]
    @Query private var profiles: [UserPracticeProfile]
    @State private var showClearConfirmation = false
    @State private var showResetOnboardingConfirmation = false
    @State private var showExperimentConfiguration = false
    @State private var selectedExperimentLabel = DebugMetricsFiltering.allLabel

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
        summaryList
    }

    private var emptyMetricsMessage: some View {
        VStack(spacing: 12) {
            Text("No metrics recorded yet")
                .font(.headline)
            Text("Use the app — record a check-in, run analysis — and metric events will appear here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var summaryList: some View {
        List {
            Section {
                ExperimentStatusRow(
                    activeLabels: experimentStore.activeLabels,
                    configureAction: { showExperimentConfiguration = true }
                )
            }

            Section("Onboarding") {
                Button("Reset onboarding", role: .destructive) {
                    showResetOnboardingConfirmation = true
                }
            }

            if events.isEmpty {
                Section {
                    emptyMetricsMessage
                }
            } else {
                Section {
                    EscalationPill(events: filteredEvents)
                }
                Section("Per-metric") {
                    filterPicker
                    if metricSummaries.isEmpty {
                        Text("No metrics match this label")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(metricSummaries, id: \.name) { summary in
                            NavigationLink(value: summary.name) {
                                MetricSummaryRow(summary: summary)
                            }
                        }
                    }
                }
            }
        }
        .contentMargins(.bottom, 112, for: .scrollContent)
        .confirmationDialog(
            "Reset onboarding?",
            isPresented: $showResetOnboardingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                resetOnboarding()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This deletes all intake profile data. Sessions and metrics are not affected.")
        }
        .navigationDestination(for: String.self) { name in
            MetricDetailView(
                metricName: name,
                experimentLabelFilter: selectedExperimentLabel == DebugMetricsFiltering.allLabel ? nil : selectedExperimentLabel
            )
        }
        .sheet(isPresented: $showExperimentConfiguration) {
            ExperimentConfigurationSheet()
        }
        .onChange(of: availableExperimentLabels) { _, labels in
            selectedExperimentLabel = DebugMetricsFiltering.normalizedSelection(
                selectedExperimentLabel,
                availableLabels: labels
            )
        }
    }

    private var filteredEvents: [MetricEvent] {
        DebugMetricsFiltering.filteredEvents(events, by: selectedExperimentLabel)
    }

    private var metricSummaries: [MetricSummary] {
        let grouped = Dictionary(grouping: filteredEvents, by: \.name)
        return grouped
            .map { name, events in
                MetricSummary(name: name, events: events)
            }
            .sorted { $0.name < $1.name }
    }

    private var availableExperimentLabels: [String] {
        DebugMetricsFiltering.availableExperimentLabels(from: events)
    }

    @ViewBuilder
    private var filterPicker: some View {
        Picker("Filter by label", selection: $selectedExperimentLabel) {
            Text(DebugMetricsFiltering.allLabel).tag(DebugMetricsFiltering.allLabel)
            ForEach(availableExperimentLabels, id: \.self) { label in
                Text(label).tag(label)
            }
        }
        .pickerStyle(.menu)
    }

    private func clearAllMetrics() {
        for event in events {
            modelContext.delete(event)
        }
        try? modelContext.save()
    }

    private func resetOnboarding() {
        for profile in profiles {
            modelContext.delete(profile)
        }
        try? modelContext.save()
    }
}

struct ExperimentStatusRow: View {
    let activeLabels: [String]
    let configureAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Experiments")
                        .font(.subheadline.weight(.medium))
                    Text(DebugExperimentPresentation.statusText(for: activeLabels))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: configureAction) {
                    Label("Configure", systemImage: "slider.horizontal.3")
                }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }

            if activeLabels.isEmpty {
                PillTag(text: "baseline", tone: .soft)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(activeLabels, id: \.self) { label in
                            PillTag(text: label, tone: .soft)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct ExperimentConfigurationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AnalysisLatencyExperimentStore.self) private var experimentStore

    var body: some View {
        NavigationStack {
            List {
                experimentControls
            }
            .navigationTitle("Experiments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var experimentControls: some View {
        @Bindable var experimentStore = experimentStore

        Section("Model") {
            Picker("Flash model", selection: $experimentStore.flashModelVariant) {
                ForEach(FlashModelVariant.allCases) { variant in
                    Text(variant.displayName).tag(variant)
                }
            }
            Picker("Response schema", selection: $experimentStore.responseSchemaMode) {
                ForEach(ResponseSchemaMode.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            Picker("Output tokens", selection: $experimentStore.outputTokenBudget) {
                ForEach(OutputTokenBudget.allCases) { budget in
                    Text("\(budget.rawValue)").tag(budget)
                }
            }
        }

        Section("Routing") {
            Picker("Confidence threshold", selection: $experimentStore.confidenceThreshold) {
                ForEach(ConfidenceThreshold.allCases) { threshold in
                    Text(String(format: "%.1f", threshold.rawValue)).tag(threshold)
                }
            }
            Toggle("Disable escalation", isOn: $experimentStore.escalationDisabled)
        }

        Section("Context and execution") {
            Toggle("Trim prompt context", isOn: $experimentStore.promptContextTrimmingEnabled)
        }
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
    let experimentLabelFilter: String?
    @Query private var events: [MetricEvent]

    init(metricName: String, experimentLabelFilter: String? = nil) {
        self.metricName = metricName
        self.experimentLabelFilter = experimentLabelFilter
        let predicate = #Predicate<MetricEvent> { $0.name == metricName }
        _events = Query(filter: predicate, sort: \MetricEvent.timestamp, order: .reverse)
    }

    private var filteredEvents: [MetricEvent] {
        guard let experimentLabelFilter else { return events }
        return events.filter { $0.analysisLatencyExperimentLabels.contains(experimentLabelFilter) }
    }

    private var p95Threshold: Int {
        let sorted = filteredEvents.map(\.durationMs).sorted()
        return MetricStats.percentile(sorted, percentile: 0.95)
    }

    var body: some View {
        List {
            if let experimentLabelFilter {
                Section("Filtered by \(experimentLabelFilter)") {
                    ForEach(filteredEvents) { event in
                        EventRow(event: event, p95Threshold: p95Threshold)
                    }
                }
            } else {
                ForEach(filteredEvents) { event in
                    EventRow(event: event, p95Threshold: p95Threshold)
                }
            }
        }
        .contentMargins(.bottom, 112, for: .scrollContent)
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
