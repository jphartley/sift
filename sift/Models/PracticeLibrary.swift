import Foundation
import Yams

struct PracticeContainer: Decodable {
    let practices: [Practice]
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

    enum CodingKeys: String, CodingKey {
        case id, name, category, labels, keywords, summary, steps, intensity
        case bestFor = "best_for"
        case whyItHelps = "why_it_helps"
        case durationMinutes = "duration_minutes"
        case avoidWhen = "avoid_when"
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
