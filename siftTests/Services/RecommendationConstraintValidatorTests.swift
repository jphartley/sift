import Foundation
import Testing
@testable import sift

struct RecommendationConstraintValidatorTests {

    init() {
        TestHelpers.setupPractices()
    }

    @Test func secularOnlyRejectsDevotionalRecommendations() throws {
        let spiritual = Practice(
            id: "prayer",
            name: "Prayer",
            category: "Spiritual / Contemplative",
            labels: ["spiritual"],
            bestFor: ["meaning"],
            keywords: ["prayer"],
            summary: "A prayer practice.",
            steps: ["Pray."],
            whyItHelps: "It can support meaning.",
            durationMinutes: 3,
            intensity: "low",
            avoidWhen: [],
            evidence: PracticeEvidence(researchBacked: false, notes: "No explicit grounding.", tags: ["spiritual"]),
            matching: PracticeMatchingMetadata(family: "prayer-or-spiritual-practice", worldview: "spiritual", bodyFocused: false, closedEye: false, breathFocused: false, devotional: true, intense: false)
        )
        let validator = RecommendationConstraintValidator(practices: [spiritual])
        let profile = UserPracticeProfile(completionState: .completed, requiresSecularFraming: true)
        let result = RecommendationResult(
            rationale: "Try this.",
            practices: [(practiceID: "prayer", relevance: "It fits.")],
            confidence: 0.8,
            modelUsed: "test",
            wasEscalated: false
        )

        #expect(throws: GeminiError.emptyPractices) {
            try validator.validate(result, profile: profile, transcript: "I feel sad")
        }
    }

    @Test func currentCheckInOverrideAllowsConstrainedPractice() throws {
        let spiritual = Practice(
            id: "prayer",
            name: "Prayer",
            category: "Spiritual / Contemplative",
            labels: ["spiritual"],
            bestFor: ["meaning"],
            keywords: ["prayer"],
            summary: "A prayer practice.",
            steps: ["Pray."],
            whyItHelps: "It can support meaning.",
            durationMinutes: 3,
            intensity: "low",
            avoidWhen: [],
            evidence: PracticeEvidence(researchBacked: false, notes: "No explicit grounding.", tags: ["spiritual"]),
            matching: PracticeMatchingMetadata(family: "prayer-or-spiritual-practice", worldview: "spiritual", bodyFocused: false, closedEye: false, breathFocused: false, devotional: true, intense: false)
        )
        let validator = RecommendationConstraintValidator(practices: [spiritual])
        let profile = UserPracticeProfile(completionState: .completed, requiresSecularFraming: true)
        let result = RecommendationResult(
            rationale: "Try this.",
            practices: [(practiceID: "prayer", relevance: "It fits.")],
            confidence: 0.8,
            modelUsed: "test",
            wasEscalated: false
        )

        let validated = try validator.validate(result, profile: profile, transcript: "I want a prayer tonight")

        #expect(validated.practices.map(\.practiceID) == ["prayer"])
    }

    @Test func currentCheckInAvoidanceDoesNotOverrideConstraint() throws {
        let validator = RecommendationConstraintValidator(practices: Practice.all)
        let profile = UserPracticeProfile(
            completionState: .completed,
            avoidedPracticeFamilies: ["breathwork"]
        )
        let result = RecommendationResult(
            rationale: "Try breathing.",
            practices: [(practiceID: "box-breathing", relevance: "It fits.")],
            confidence: 0.8,
            modelUsed: "test",
            wasEscalated: false
        )

        #expect(throws: GeminiError.emptyPractices) {
            try validator.validate(result, profile: profile, transcript: "I still want to avoid breathwork tonight")
        }
    }

    @Test func researchBackedOnlyRejectsUngroundedRecommendations() throws {
        let validator = RecommendationConstraintValidator(practices: Practice.all)
        let profile = UserPracticeProfile(completionState: .completed, requiresEvidenceGrounding: true)
        let ungroundedID = try #require(Practice.all.first { !$0.evidence.researchBacked }?.id)
        let result = RecommendationResult(
            rationale: "Try this.",
            practices: [(practiceID: ungroundedID, relevance: "It fits.")],
            confidence: 0.8,
            modelUsed: "test",
            wasEscalated: false
        )

        #expect(throws: GeminiError.emptyPractices) {
            try validator.validate(result, profile: profile, transcript: "I feel stuck")
        }
    }

    @Test func excludedPracticeFamilyIsRejected() throws {
        let validator = RecommendationConstraintValidator(practices: Practice.all)
        let profile = UserPracticeProfile(
            completionState: .completed,
            avoidedPracticeFamilies: ["breathwork"]
        )
        let result = RecommendationResult(
            rationale: "Try breathing.",
            practices: [(practiceID: "box-breathing", relevance: "It fits.")],
            confidence: 0.8,
            modelUsed: "test",
            wasEscalated: false
        )

        #expect(throws: GeminiError.emptyPractices) {
            try validator.validate(result, profile: profile, transcript: "I feel anxious")
        }
    }

    @Test func softPriorDoesNotRejectPractice() throws {
        let validator = RecommendationConstraintValidator(practices: Practice.all)
        let profile = UserPracticeProfile(
            completionState: .completed,
            softPriors: ["breathwork helped sometimes; recommend it only when especially relevant."],
            loweredPriorityPracticeFamilies: ["breathwork"]
        )
        let result = RecommendationResult(
            rationale: "Try breathing.",
            practices: [(practiceID: "box-breathing", relevance: "It fits.")],
            confidence: 0.8,
            modelUsed: "test",
            wasEscalated: false
        )

        let validated = try validator.validate(result, profile: profile, transcript: "I feel anxious")

        #expect(validated.practices.map { $0.practiceID } == ["box-breathing"])
    }
}
