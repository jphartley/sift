import Foundation

struct RecommendationConstraintValidator {
    var practices: [Practice] = Practice.all

    func validate(
        _ result: RecommendationResult,
        profile: UserPracticeProfile?,
        transcript: String
    ) throws -> RecommendationResult {
        guard let profile, profile.completionState == .completed else {
            return result
        }
        let practiceByID = Dictionary(uniqueKeysWithValues: practices.map { ($0.id, $0) })
        let validPractices = result.practices.filter { recommendation in
            guard let practice = practiceByID[recommendation.practiceID] else { return false }
            return isAllowed(practice: practice, profile: profile, transcript: transcript)
        }
        guard !validPractices.isEmpty else {
            throw GeminiError.emptyPractices
        }
        return RecommendationResult(
            rationale: result.rationale,
            practices: validPractices,
            confidence: result.confidence,
            modelUsed: result.modelUsed,
            wasEscalated: result.wasEscalated
        )
    }

    func isAllowed(practice: Practice, profile: UserPracticeProfile, transcript: String) -> Bool {
        if hasCurrentCheckInOverride(for: practice, transcript: transcript) {
            return true
        }
        if profile.requiresEvidenceGrounding && !practice.evidence.researchBacked {
            return false
        }
        if profile.requiresSecularFraming && (practice.matching.devotional || practice.matching.worldview == "spiritual") {
            return false
        }
        if profile.avoidedPracticeFamilies.contains(practice.matching.family) {
            return false
        }
        if profile.avoidsBodyFocused && practice.matching.bodyFocused {
            return false
        }
        if profile.avoidsClosedEye && practice.matching.closedEye {
            return false
        }
        if profile.avoidsBreathFocused && practice.matching.breathFocused {
            return false
        }
        if profile.avoidsIntensePractices && practice.matching.intense {
            return false
        }
        return true
    }

    private func hasCurrentCheckInOverride(for practice: Practice, transcript: String) -> Bool {
        let text = transcript.lowercased()
        let name = practice.name.lowercased()
        let family = practice.matching.family
        if text.contains("avoid \(name)") || text.contains("no \(name)") || text.contains("not \(name)") {
            return false
        }
        if text.contains("avoid \(family)") || text.contains("no \(family)") || text.contains("not \(family)") {
            return false
        }
        if text.contains(name) || text.contains(practice.matching.family) {
            return true
        }
        if practice.matching.devotional && (text.contains("prayer") || text.contains("pray") || text.contains("spiritual practice")) {
            return true
        }
        return false
    }
}
