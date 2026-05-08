import Foundation
import SwiftData
import Testing
@testable import sift

@MainActor
struct SwiftDataTests {

    private func makeContainer() throws -> ModelContainer {
        try TestHelpers.makeContainer()
    }

    @Test func cascadeDeleteRemovesAttempts() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let session = Session(transcript: "test")
        let attempt1 = PracticeAttempt(practiceID: "a", practiceName: "A")
        let attempt2 = PracticeAttempt(practiceID: "b", practiceName: "B")
        session.attempts.append(attempt1)
        session.attempts.append(attempt2)

        context.insert(session)
        try context.save()

        var sessionFetch = FetchDescriptor<Session>()
        var sessions = try context.fetch(sessionFetch)
        #expect(sessions.count == 1)

        var attemptFetch = FetchDescriptor<PracticeAttempt>()
        var attempts = try context.fetch(attemptFetch)
        #expect(attempts.count == 2)

        context.delete(sessions[0])
        try context.save()

        sessions = try context.fetch(sessionFetch)
        #expect(sessions.isEmpty)

        attempts = try context.fetch(attemptFetch)
        #expect(attempts.isEmpty)
    }

    @Test func sessionStoreDeleteRemovesAttempts() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = SwiftDataSessionStore(modelContext: context)

        let session = Session(transcript: "test")
        session.attempts.append(PracticeAttempt(practiceID: "a", practiceName: "A"))
        session.attempts.append(PracticeAttempt(practiceID: "b", practiceName: "B"))
        context.insert(session)
        try context.save()

        try store.delete([session])

        let sessions = try context.fetch(FetchDescriptor<Session>())
        let attempts = try context.fetch(FetchDescriptor<PracticeAttempt>())
        #expect(sessions.isEmpty)
        #expect(attempts.isEmpty)
    }

    @Test func wasHelpfulPredicateFiltersCorrectly() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let helpful = PracticeAttempt(
            practiceID: "box-breathing",
            practiceName: "Box Breathing",
            wasHelpful: true
        )
        let notHelpful = PracticeAttempt(
            practiceID: "body-scan",
            practiceName: "Body Scan",
            wasHelpful: false
        )
        let unrated = PracticeAttempt(
            practiceID: "short-walk",
            practiceName: "Short Walk",
            wasHelpful: nil
        )

        context.insert(helpful)
        context.insert(notHelpful)
        context.insert(unrated)
        try context.save()

        let helpfulDescriptor = FetchDescriptor<PracticeAttempt>(
            predicate: #Predicate { $0.wasHelpful == true }
        )
        let helpfulResults = try context.fetch(helpfulDescriptor)
        #expect(helpfulResults.count == 1)
        #expect(helpfulResults[0].practiceID == "box-breathing")

        let notHelpfulDescriptor = FetchDescriptor<PracticeAttempt>(
            predicate: #Predicate { $0.wasHelpful == false }
        )
        let notHelpfulResults = try context.fetch(notHelpfulDescriptor)
        #expect(notHelpfulResults.count == 1)
        #expect(notHelpfulResults[0].practiceID == "body-scan")
    }

    @Test func sessionPersistsGeminiFields() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let session = Session(transcript: "test")
        session.geminiRationale = "You seem tired"
        session.geminiModelUsed = "gemini-3-flash-preview"
        session.geminiConfidence = 0.9

        context.insert(session)
        try context.save()

        let fetchDescriptor = FetchDescriptor<Session>()
        let sessions = try context.fetch(fetchDescriptor)
        #expect(sessions.count == 1)
        #expect(sessions[0].geminiRationale == "You seem tired")
        #expect(sessions[0].geminiModelUsed == "gemini-3-flash-preview")
        #expect(sessions[0].geminiConfidence == 0.9)
    }

    @Test func sessionGeminiFieldsNilByDefault() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let session = Session(transcript: "test")
        context.insert(session)
        try context.save()

        let fetchDescriptor = FetchDescriptor<Session>()
        let sessions = try context.fetch(fetchDescriptor)
        #expect(sessions[0].geminiRationale == nil)
        #expect(sessions[0].geminiModelUsed == nil)
        #expect(sessions[0].geminiConfidence == nil)
    }
}
