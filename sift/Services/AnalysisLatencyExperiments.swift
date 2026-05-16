import Foundation

enum FlashModelVariant: String, CaseIterable, Identifiable {
    case preview
    case stable

    var id: String { rawValue }

    var modelName: String {
        switch self {
        case .preview: return GeminiRecommendationRouter.flashModel
        case .stable: return "gemini-2.5-flash"
        }
    }

    var displayName: String {
        switch self {
        case .preview: return "3 Preview"
        case .stable: return "2.5 Stable"
        }
    }

    var label: String {
        switch self {
        case .preview: return "flash=3-preview"
        case .stable: return "flash=2.5-stable"
        }
    }
}

enum ResponseSchemaMode: String, CaseIterable, Identifiable {
    case strict
    case relaxed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .strict: return "schema=strict"
        case .relaxed: return "schema=relaxed"
        }
    }
}

enum OutputTokenBudget: Int, CaseIterable, Identifiable {
    case standard = 4096
    case reduced = 1024

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .standard: return "output=4096"
        case .reduced: return "output=1024"
        }
    }
}

enum ConfidenceThreshold: Double, CaseIterable, Identifiable {
    case standard = 0.7
    case reduced = 0.5

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .standard: return "threshold=0.7"
        case .reduced: return "threshold=0.5"
        }
    }
}

struct AnalysisLatencyExperimentSnapshot: Equatable {
    var flashModelVariant: FlashModelVariant = .preview
    var responseSchemaMode: ResponseSchemaMode = .strict
    var promptContextTrimmingEnabled = false
    var outputTokenBudget: OutputTokenBudget = .standard
    var confidenceThreshold: ConfidenceThreshold = .standard
    var escalationDisabled = false
    var contextCachingEnabled = false
    var speculativeParallelEnabled = false
    var streamingEnabled = false

    static let baseline = AnalysisLatencyExperimentSnapshot()

    var flashModelName: String {
        flashModelVariant.modelName
    }

    var responseSchemaIsStrict: Bool {
        responseSchemaMode == .strict
    }

    var activeLabels: [String] {
        var labels: [String] = []
        if flashModelVariant != .preview { labels.append(flashModelVariant.label) }
        if responseSchemaMode == .relaxed { labels.append(responseSchemaMode.label) }
        if promptContextTrimmingEnabled { labels.append("prompt=trimmed") }
        if outputTokenBudget == .reduced { labels.append(outputTokenBudget.label) }
        if confidenceThreshold == .reduced { labels.append(confidenceThreshold.label) }
        if escalationDisabled { labels.append("escalation=off") }
        if contextCachingEnabled { labels.append("cache=on") }
        if speculativeParallelEnabled { labels.append("parallel=on") }
        if streamingEnabled { labels.append("streaming=on") }
        return labels
    }

    var metricMetadata: [String: String] {
        guard !activeLabels.isEmpty else { return [:] }
        return ["analysis.experiments": activeLabels.joined(separator: "|")]
    }

    var generationProfile: GeminiGenerationProfile {
        GeminiGenerationProfile(
            maxOutputTokens: outputTokenBudget.rawValue,
            responseSchemaIsStrict: responseSchemaIsStrict
        )
    }
}

@Observable
final class AnalysisLatencyExperimentStore {
    var flashModelVariant: FlashModelVariant = .preview
    var responseSchemaMode: ResponseSchemaMode = .strict
    var promptContextTrimmingEnabled = false
    var outputTokenBudget: OutputTokenBudget = .standard
    var confidenceThreshold: ConfidenceThreshold = .standard
    var escalationDisabled = false
    var contextCachingEnabled = false
    var speculativeParallelEnabled = false
    var streamingEnabled = false

    var snapshot: AnalysisLatencyExperimentSnapshot {
        AnalysisLatencyExperimentSnapshot(
            flashModelVariant: flashModelVariant,
            responseSchemaMode: responseSchemaMode,
            promptContextTrimmingEnabled: promptContextTrimmingEnabled,
            outputTokenBudget: outputTokenBudget,
            confidenceThreshold: confidenceThreshold,
            escalationDisabled: escalationDisabled,
            contextCachingEnabled: contextCachingEnabled,
            speculativeParallelEnabled: speculativeParallelEnabled,
            streamingEnabled: streamingEnabled
        )
    }

    var activeLabels: [String] {
        snapshot.activeLabels
    }

    var hasActiveExperiments: Bool {
        !activeLabels.isEmpty
    }
}

struct GeminiGenerationProfile: Equatable {
    let maxOutputTokens: Int
    let responseSchemaIsStrict: Bool

    var responseMIMEType: String? {
        responseSchemaIsStrict ? "application/json" : nil
    }
}
