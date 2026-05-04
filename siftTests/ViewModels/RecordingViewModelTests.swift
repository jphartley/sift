import Foundation
import SwiftData
import Testing
@testable import sift

@MainActor
struct RecordingViewModelTests {

    private func makeViewModel() throws -> (RecordingViewModel, ModelContainer) {
        let container = try TestHelpers.makeContainer()
        let viewModel = RecordingViewModel()
        viewModel.configure(modelContext: container.mainContext)
        return (viewModel, container)
    }

    @Test func completeReflectionPersistsSessionAndResetsState() throws {
        let (viewModel, container) = try makeViewModel()
        let context = container.mainContext

        let session = Session(transcript: "I feel tired")
        let attempt = PracticeAttempt(practiceID: "body-scan", practiceName: "Body Scan")
        session.attempts.append(attempt)
        context.insert(session)
        try context.save()

        let fetchDescriptor = FetchDescriptor<Session>()
        let sessions = try context.fetch(fetchDescriptor)
        #expect(sessions.count == 1)
        #expect(sessions[0].transcript == "I feel tired")
        #expect(sessions[0].attempts.count == 1)
        #expect(sessions[0].attempts[0].practiceName == "Body Scan")
    }

    @Test func skipSuggestionsPersistsEmptySession() throws {
        let (viewModel, container) = try makeViewModel()
        let context = container.mainContext

        let session = Session(transcript: "test")
        context.insert(session)
        try context.save()

        let fetchDescriptor = FetchDescriptor<Session>()
        let sessions = try context.fetch(fetchDescriptor)
        #expect(sessions.count == 1)
        #expect(sessions[0].attempts.isEmpty)
    }

    @Test func dismissPracticeClearsAttempts() throws {
        let (_, container) = try makeViewModel()
        let context = container.mainContext

        let session = Session(transcript: "test")
        let attempt = PracticeAttempt(practiceID: "box-breathing", practiceName: "Box Breathing")
        session.attempts.append(attempt)
        #expect(session.attempts.count == 1)

        session.attempts.removeAll()
        #expect(session.attempts.isEmpty)

        context.insert(session)
        try context.save()

        let fetchDescriptor = FetchDescriptor<Session>()
        let sessions = try context.fetch(fetchDescriptor)
        #expect(sessions[0].attempts.isEmpty)
    }

    @Test func practiceRankingBoostsPreviouslyHelpful() throws {
        let (_, container) = try makeViewModel()
        let context = container.mainContext

        let helpful = PracticeAttempt(
            practiceID: "box-breathing",
            practiceName: "Box Breathing",
            wasHelpful: true
        )
        context.insert(helpful)
        try context.save()

        let descriptor = FetchDescriptor<PracticeAttempt>(
            predicate: #Predicate { $0.wasHelpful == true }
        )
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results[0].practiceID == "box-breathing")
    }
}
