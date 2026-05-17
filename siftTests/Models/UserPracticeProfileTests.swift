import Foundation
import SwiftData
import Testing
@testable import sift

@MainActor
struct UserPracticeProfileTests {

    @Test func defaultProfileIsAbsent() throws {
        let container = try TestHelpers.makeContainer()
        let store = SwiftDataUserPracticeProfileStore(modelContext: ModelContext(container))

        let profile = try store.currentProfile()
        #expect(profile == nil)
    }

    @Test func skippedIntakeStatePersists() throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        let store = SwiftDataUserPracticeProfileStore(modelContext: context)

        try store.markSkipped()

        let fetchedProfile = try store.currentProfile()
        let profile = try #require(fetchedProfile)
        #expect(profile.completionState == .skipped)
        #expect(profile.hardConstraints.isEmpty)
        #expect(!profile.requiresSecularFraming)
        #expect(!profile.requiresEvidenceGrounding)
    }

    @Test func completedIntakeStatePersists() throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        let store = SwiftDataUserPracticeProfileStore(modelContext: context)
        let profile = UserPracticeProfile(
            completionState: .completed,
            optionalTuningCompleted: true,
            desiredSupportAreas: ["Calming down", "Finding focus"],
            hardConstraints: ["Use secular framing"],
            softPriors: ["Prefer practical guidance"],
            avoidedPracticeFamilies: ["breathwork"],
            preferredPracticeFamilies: ["journaling"],
            loweredPriorityPracticeFamilies: ["meditation"],
            coachingStyles: ["Gentle", "Brief"],
            sourceNotes: ["Voice note summary"],
            requiresSecularFraming: true,
            allowsSpiritualLanguage: true,
            requiresEvidenceGrounding: true,
            avoidsBodyFocused: true,
            avoidsClosedEye: true,
            preferredDurationMaxMinutes: 5
        )

        try store.save(profile)

        let fetchedProfile = try store.currentProfile()
        let saved = try #require(fetchedProfile)
        #expect(saved.completionState == .completed)
        #expect(saved.optionalTuningCompleted)
        #expect(saved.desiredSupportAreas == ["Calming down", "Finding focus"])
        #expect(saved.hardConstraints == ["Use secular framing"])
        #expect(saved.softPriors == ["Prefer practical guidance"])
        #expect(saved.avoidedPracticeFamilies == ["breathwork"])
        #expect(saved.preferredPracticeFamilies == ["journaling"])
        #expect(saved.loweredPriorityPracticeFamilies == ["meditation"])
        #expect(saved.coachingStyles == ["Gentle", "Brief"])
        #expect(saved.sourceNotes == ["Voice note summary"])
        #expect(saved.requiresSecularFraming)
        #expect(saved.allowsSpiritualLanguage)
        #expect(saved.requiresEvidenceGrounding)
        #expect(saved.avoidsBodyFocused)
        #expect(saved.avoidsClosedEye)
        #expect(saved.preferredDurationMaxMinutes == 5)
    }

    @Test func savingASecondProfileReplacesExistingProfile() throws {
        let container = try TestHelpers.makeContainer()
        let context = ModelContext(container)
        let store = SwiftDataUserPracticeProfileStore(modelContext: context)

        try store.markSkipped()
        try store.save(UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["Sleeping better"],
            preferredPracticeFamilies: ["grounding"]
        ))

        let descriptor = FetchDescriptor<UserPracticeProfile>()
        let profiles = try context.fetch(descriptor)
        let saved = try #require(profiles.first)

        #expect(profiles.count == 1)
        #expect(saved.completionState == .completed)
        #expect(saved.desiredSupportAreas == ["Sleeping better"])
        #expect(saved.preferredPracticeFamilies == ["grounding"])
    }
}
