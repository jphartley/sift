#if DEBUG
import Testing
import SwiftData
@testable import sift

@MainActor
struct DebugMetricsResetTests {
    @Test func resetDeletesAllProfiles() async throws {
        let container = try TestHelpers.makeContainer()
        let context = container.mainContext

        context.insert(UserPracticeProfile(completionState: .completed))
        context.insert(UserPracticeProfile(completionState: .skipped))
        try context.save()

        let profiles = try context.fetch(FetchDescriptor<UserPracticeProfile>())
        #expect(profiles.count == 2)

        for profile in profiles {
            context.delete(profile)
        }
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<UserPracticeProfile>())
        #expect(remaining.isEmpty)
    }

    @Test func resetLeavesOtherEntitiesUntouched() async throws {
        let container = try TestHelpers.makeContainer()
        let context = container.mainContext

        context.insert(UserPracticeProfile(completionState: .completed))
        context.insert(Session(transcript: "test", audioDuration: 1, transcriptionDurationMs: 1000))
        context.insert(MetricEvent(name: "gemini.flash", durationMs: 100))
        try context.save()

        let profiles = try context.fetch(FetchDescriptor<UserPracticeProfile>())
        for profile in profiles {
            context.delete(profile)
        }
        try context.save()

        let sessions = try context.fetch(FetchDescriptor<Session>())
        let events = try context.fetch(FetchDescriptor<MetricEvent>())
        #expect(sessions.count == 1)
        #expect(events.count == 1)
    }

    @Test func cancelLeavesProfilesUnchanged() async throws {
        let container = try TestHelpers.makeContainer()
        let context = container.mainContext

        context.insert(UserPracticeProfile(completionState: .completed))
        try context.save()

        let before = try context.fetch(FetchDescriptor<UserPracticeProfile>())
        #expect(before.count == 1)

        let after = try context.fetch(FetchDescriptor<UserPracticeProfile>())
        #expect(after.count == 1)
    }
}
#endif
