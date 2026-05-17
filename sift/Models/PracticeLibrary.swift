import Foundation
import Yams

struct PracticeContainer: Decodable {
    let practices: [Practice]
}

struct PracticeEvidence: Equatable, Hashable, Decodable {
    let researchBacked: Bool
    let notes: String
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case researchBacked = "research_backed"
        case notes, tags
    }
}

struct PracticeMatchingMetadata: Equatable, Hashable, Decodable {
    let family: String
    let worldview: String
    let bodyFocused: Bool
    let closedEye: Bool
    let breathFocused: Bool
    let devotional: Bool
    let intense: Bool

    enum CodingKeys: String, CodingKey {
        case family, worldview, devotional, intense
        case bodyFocused = "body_focused"
        case closedEye = "closed_eye"
        case breathFocused = "breath_focused"
    }
}

struct Practice: Identifiable, Equatable, Hashable, Decodable {
    let id: String
    let name: String
    let category: String
    let labels: [String]
    let bestFor: [String]
    let keywords: [String]
    let summary: String
    let steps: [String]
    let whyItHelps: String
    let durationMinutes: Int
    let intensity: String
    let avoidWhen: [String]
    let evidence: PracticeEvidence
    let matching: PracticeMatchingMetadata

    enum CodingKeys: String, CodingKey {
        case id, name, category, labels, keywords, summary, steps, intensity, evidence, matching
        case bestFor = "best_for"
        case whyItHelps = "why_it_helps"
        case durationMinutes = "duration_minutes"
        case avoidWhen = "avoid_when"
    }

    init(
        id: String,
        name: String,
        category: String,
        labels: [String],
        bestFor: [String],
        keywords: [String],
        summary: String,
        steps: [String],
        whyItHelps: String,
        durationMinutes: Int,
        intensity: String,
        avoidWhen: [String],
        evidence: PracticeEvidence = PracticeEvidence(
            researchBacked: false,
            notes: "No explicit research grounding is marked for this in-code practice.",
            tags: ["unspecified"]
        ),
        matching: PracticeMatchingMetadata = PracticeMatchingMetadata(
            family: "unspecified",
            worldview: "secular",
            bodyFocused: false,
            closedEye: false,
            breathFocused: false,
            devotional: false,
            intense: false
        )
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.labels = labels
        self.bestFor = bestFor
        self.keywords = keywords
        self.summary = summary
        self.steps = steps
        self.whyItHelps = whyItHelps
        self.durationMinutes = durationMinutes
        self.intensity = intensity
        self.avoidWhen = avoidWhen
        self.evidence = evidence
        self.matching = matching
    }

    static let yamlFileName = "practices"

    private static var _all: [Practice]?

    static var all: [Practice] {
        get {
            if let cached = _all { return cached }
            do {
                guard let url = Bundle.main.url(forResource: yamlFileName, withExtension: "yaml") else {
                    fatalError("Practice library file '\(yamlFileName).yaml' not found in app bundle.")
                }
                let yamlString = try String(contentsOf: url, encoding: .utf8)
                _all = try YAMLDecoder().decode(PracticeContainer.self, from: yamlString).practices
                return _all!
            } catch {
                fatalError("Failed to load practice library: \(error)")
            }
        }
        set { _all = newValue }
    }

    static func load(from yamlString: String) throws -> [Practice] {
        let container = try YAMLDecoder().decode(PracticeContainer.self, from: yamlString)
        return container.practices
    }
}

enum PracticeLibraryError: LocalizedError {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Practice library file not found in app bundle."
        }
    }
}
