import Foundation
import SwiftData

enum IntakeCompletionState: String, Codable, Equatable {
    case skipped
    case completed
}

enum PracticeExperienceSignal: String, Codable, Equatable, CaseIterable {
    case workedForMe
    case helpedSometimes
    case didNotReallyHelp
    case pleaseAvoid
}

struct PracticeFamilyPreference: Codable, Equatable, Hashable {
    var family: String
    var signal: PracticeExperienceSignal
}

@Model
final class UserPracticeProfile {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var completionStateRaw: String
    var optionalTuningCompleted: Bool
    var desiredSupportAreasJSON: String
    var practiceHistoryJSON: String
    var hardConstraintsJSON: String
    var softPriorsJSON: String
    var avoidedPracticeFamiliesJSON: String
    var preferredPracticeFamiliesJSON: String
    var loweredPriorityPracticeFamiliesJSON: String
    var coachingStylesJSON: String
    var sourceNotesJSON: String
    var requiresSecularFraming: Bool
    var allowsSpiritualLanguage: Bool
    var requiresEvidenceGrounding: Bool
    var avoidsBodyFocused: Bool
    var avoidsClosedEye: Bool
    var avoidsBreathFocused: Bool
    var avoidsIntensePractices: Bool
    var preferredDurationMaxMinutes: Int?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completionState: IntakeCompletionState,
        optionalTuningCompleted: Bool = false,
        desiredSupportAreas: [String] = [],
        practiceHistory: [PracticeFamilyPreference] = [],
        hardConstraints: [String] = [],
        softPriors: [String] = [],
        avoidedPracticeFamilies: [String] = [],
        preferredPracticeFamilies: [String] = [],
        loweredPriorityPracticeFamilies: [String] = [],
        coachingStyles: [String] = [],
        sourceNotes: [String] = [],
        requiresSecularFraming: Bool = false,
        allowsSpiritualLanguage: Bool = false,
        requiresEvidenceGrounding: Bool = false,
        avoidsBodyFocused: Bool = false,
        avoidsClosedEye: Bool = false,
        avoidsBreathFocused: Bool = false,
        avoidsIntensePractices: Bool = false,
        preferredDurationMaxMinutes: Int? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completionStateRaw = completionState.rawValue
        self.optionalTuningCompleted = optionalTuningCompleted
        self.desiredSupportAreasJSON = Self.encode(desiredSupportAreas)
        self.practiceHistoryJSON = Self.encode(practiceHistory)
        self.hardConstraintsJSON = Self.encode(hardConstraints)
        self.softPriorsJSON = Self.encode(softPriors)
        self.avoidedPracticeFamiliesJSON = Self.encode(avoidedPracticeFamilies)
        self.preferredPracticeFamiliesJSON = Self.encode(preferredPracticeFamilies)
        self.loweredPriorityPracticeFamiliesJSON = Self.encode(loweredPriorityPracticeFamilies)
        self.coachingStylesJSON = Self.encode(coachingStyles)
        self.sourceNotesJSON = Self.encode(sourceNotes)
        self.requiresSecularFraming = requiresSecularFraming
        self.allowsSpiritualLanguage = allowsSpiritualLanguage
        self.requiresEvidenceGrounding = requiresEvidenceGrounding
        self.avoidsBodyFocused = avoidsBodyFocused
        self.avoidsClosedEye = avoidsClosedEye
        self.avoidsBreathFocused = avoidsBreathFocused
        self.avoidsIntensePractices = avoidsIntensePractices
        self.preferredDurationMaxMinutes = preferredDurationMaxMinutes
    }

    var completionState: IntakeCompletionState {
        IntakeCompletionState(rawValue: completionStateRaw) ?? .skipped
    }

    var desiredSupportAreas: [String] {
        Self.decode([String].self, from: desiredSupportAreasJSON) ?? []
    }

    var practiceHistory: [PracticeFamilyPreference] {
        Self.decode([PracticeFamilyPreference].self, from: practiceHistoryJSON) ?? []
    }

    var hardConstraints: [String] {
        Self.decode([String].self, from: hardConstraintsJSON) ?? []
    }

    var softPriors: [String] {
        Self.decode([String].self, from: softPriorsJSON) ?? []
    }

    var avoidedPracticeFamilies: [String] {
        Self.decode([String].self, from: avoidedPracticeFamiliesJSON) ?? []
    }

    var preferredPracticeFamilies: [String] {
        Self.decode([String].self, from: preferredPracticeFamiliesJSON) ?? []
    }

    var loweredPriorityPracticeFamilies: [String] {
        Self.decode([String].self, from: loweredPriorityPracticeFamiliesJSON) ?? []
    }

    var coachingStyles: [String] {
        Self.decode([String].self, from: coachingStylesJSON) ?? []
    }

    var sourceNotes: [String] {
        Self.decode([String].self, from: sourceNotesJSON) ?? []
    }

    static func skipped(now: Date = Date()) -> UserPracticeProfile {
        UserPracticeProfile(
            createdAt: now,
            updatedAt: now,
            completionState: .skipped
        )
    }

    func replace(with profile: UserPracticeProfile, now: Date = Date()) {
        completionStateRaw = profile.completionStateRaw
        optionalTuningCompleted = profile.optionalTuningCompleted
        desiredSupportAreasJSON = profile.desiredSupportAreasJSON
        practiceHistoryJSON = profile.practiceHistoryJSON
        hardConstraintsJSON = profile.hardConstraintsJSON
        softPriorsJSON = profile.softPriorsJSON
        avoidedPracticeFamiliesJSON = profile.avoidedPracticeFamiliesJSON
        preferredPracticeFamiliesJSON = profile.preferredPracticeFamiliesJSON
        loweredPriorityPracticeFamiliesJSON = profile.loweredPriorityPracticeFamiliesJSON
        coachingStylesJSON = profile.coachingStylesJSON
        sourceNotesJSON = profile.sourceNotesJSON
        requiresSecularFraming = profile.requiresSecularFraming
        allowsSpiritualLanguage = profile.allowsSpiritualLanguage
        requiresEvidenceGrounding = profile.requiresEvidenceGrounding
        avoidsBodyFocused = profile.avoidsBodyFocused
        avoidsClosedEye = profile.avoidsClosedEye
        avoidsBreathFocused = profile.avoidsBreathFocused
        avoidsIntensePractices = profile.avoidsIntensePractices
        preferredDurationMaxMinutes = profile.preferredDurationMaxMinutes
        updatedAt = now
    }

    private static func encode<T: Encodable>(_ value: T) -> String {
        guard let data = try? JSONEncoder().encode(value) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    private static func decode<T: Decodable>(_ type: T.Type, from string: String) -> T? {
        guard let data = string.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
