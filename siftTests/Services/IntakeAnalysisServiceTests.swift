import Foundation
import Testing
@testable import sift

struct IntakeAnalysisServiceTests {
    private let analyzer = LocalIntakeAnalyzer()

    @Test func secularOnlyCreatesHardConstraint() async throws {
        let profile = try await analyzer.analyze(
            responses: [
                IntakeResponse(promptID: .boundaries, selectedChipIDs: ["secular-only"])
            ],
            optionalTuningCompleted: false
        )

        #expect(profile.requiresSecularFraming)
        #expect(profile.hardConstraints.contains { $0.contains("Use secular framing") })
    }

    @Test func researchBackedOnlyCreatesEvidenceConstraint() async throws {
        let profile = try await analyzer.analyze(
            responses: [
                IntakeResponse(promptID: .boundaries, selectedChipIDs: ["research-backed-only"])
            ],
            optionalTuningCompleted: false
        )

        #expect(profile.requiresEvidenceGrounding)
        #expect(profile.hardConstraints.contains("Recommend only practices with explicit evidence grounding."))
    }

    @Test func explicitPracticeFamilyAvoidanceIsHardConstraint() async throws {
        let response = IntakeResponse(
            promptID: .priorPractice,
            selectedChipIDs: ["meditation"],
            practiceSignals: ["meditation": .pleaseAvoid]
        )

        let profile = try await analyzer.analyze(responses: [response], optionalTuningCompleted: false)

        #expect(profile.avoidedPracticeFamilies == ["meditation"])
        #expect(profile.hardConstraints.contains("Avoid meditation practices."))
    }

    @Test func helpedSometimesIsSoftPriorNotExclusion() async throws {
        let response = IntakeResponse(
            promptID: .priorPractice,
            selectedChipIDs: ["breathwork"],
            practiceSignals: ["breathwork": .helpedSometimes]
        )

        let profile = try await analyzer.analyze(responses: [response], optionalTuningCompleted: false)

        #expect(profile.loweredPriorityPracticeFamilies == ["breathwork"])
        #expect(profile.avoidedPracticeFamilies.isEmpty)
        #expect(profile.softPriors.contains("breathwork helped sometimes; recommend it only when especially relevant."))
    }

    @Test func mixedPreferencesArePreservedConservatively() async throws {
        let response = IntakeResponse(
            promptID: .boundaries,
            selectedChipIDs: ["secular-only", "spiritual-language-okay", "practical-guidance"]
        )

        let profile = try await analyzer.analyze(responses: [response], optionalTuningCompleted: false)

        #expect(profile.requiresSecularFraming)
        #expect(profile.allowsSpiritualLanguage)
        #expect(profile.hardConstraints.contains { $0.contains("Use secular framing") })
        #expect(profile.softPriors.contains("Spiritual or contemplative language is okay when it remains compatible with hard constraints."))
        #expect(profile.softPriors.contains("Prefer grounded, usable guidance."))
    }

    @Test func skippedAnswersCreateNoRestrictiveConstraints() async throws {
        let profile = try await analyzer.analyze(responses: [], optionalTuningCompleted: false)

        #expect(profile.hardConstraints.isEmpty)
        #expect(profile.softPriors.isEmpty)
        #expect(profile.desiredSupportAreas.isEmpty)
        #expect(!profile.requiresSecularFraming)
        #expect(!profile.requiresEvidenceGrounding)
    }

    @Test func voiceAnswerCanInferConservativeAvoidance() async throws {
        let response = IntakeResponse(
            promptID: .boundaries,
            voiceTranscript: "Please avoid breathwork and closed eye practices for now."
        )

        let profile = try await analyzer.analyze(responses: [response], optionalTuningCompleted: false)

        #expect(profile.avoidsBreathFocused)
        #expect(profile.avoidsClosedEye)
        #expect(profile.avoidedPracticeFamilies == ["breathwork"])
    }
}
