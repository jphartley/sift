import Foundation
import SwiftData
import Testing
@testable import sift

@MainActor
struct SwiftDataTests {

    private func makeContainer() throws -> ModelContainer {
        try TestHelpers.makeContainer()
    }

    private func makeSession(
        index: Int,
        wasHelpful: Bool? = nil,
        practiceName: String? = nil
    ) -> Session {
        let session = Session(
            timestamp: Date(timeIntervalSince1970: Double(index)),
            transcript: "full transcript \(index)"
        )
        if let practiceName {
            session.attempts.append(PracticeAttempt(
                practiceID: "practice-\(index)",
                practiceName: practiceName,
                wasHelpful: wasHelpful
            ))
        }
        return session
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

        let sessionFetch = FetchDescriptor<Session>()
        var sessions = try context.fetch(sessionFetch)
        #expect(sessions.count == 1)

        let attemptFetch = FetchDescriptor<PracticeAttempt>()
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

    @Test func recommendationHistoryIncludesAllSessionsUnderLimit() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = SwiftDataSessionStore(modelContext: context)

        for index in 0..<5 {
            context.insert(makeSession(
                index: index,
                wasHelpful: index == 1,
                practiceName: index == 1 ? "Helpful Practice" : nil
            ))
        }
        try context.save()

        let history = try store.recommendationHistory()

        #expect(history.count == 5)
        #expect(history.map(\.transcript) == [
            "full transcript 4",
            "full transcript 3",
            "full transcript 2",
            "full transcript 1",
            "full transcript 0",
        ])
        #expect(history[3].practiceName == "Helpful Practice")
        #expect(history[3].wasHelpful == true)
    }

    @Test func recommendationHistoryReturnsEmptyForNoSessions() throws {
        let container = try makeContainer()
        let store = SwiftDataSessionStore(modelContext: container.mainContext)

        let history = try store.recommendationHistory()

        #expect(history.isEmpty)
    }

    @Test func recommendationHistoryReturnsAllSessionsAtExactLimit() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = SwiftDataSessionStore(modelContext: context)

        for index in 0..<20 {
            context.insert(makeSession(index: index))
        }
        try context.save()

        let history = try store.recommendationHistory()

        #expect(history.count == 20)
    }

    @Test func recommendationHistoryDropsUnhelpfulOlderSessionsBeyondLimit() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = SwiftDataSessionStore(modelContext: context)

        for index in 0..<21 {
            context.insert(makeSession(index: index))
        }
        try context.save()

        let history = try store.recommendationHistory()

        // Only the 10 most recent are kept; no helpful older sessions to supplement
        #expect(history.count == 10)
        let transcripts = history.map(\.transcript)
        #expect(transcripts.first == "full transcript 20")
        #expect(transcripts.last == "full transcript 11")
        #expect(!transcripts.contains("full transcript 10"))
    }

    @Test func recommendationHistoryCapsHelpfulOlderSessionsAtTen() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = SwiftDataSessionStore(modelContext: context)

        // 30 sessions: indices 20–29 are the 10 most recent; indices 0–14 are all helpful
        for index in 0..<30 {
            let isHelpfulOlder = index < 15
            context.insert(makeSession(
                index: index,
                wasHelpful: isHelpfulOlder ? true : nil,
                practiceName: isHelpfulOlder ? "Practice \(index)" : nil
            ))
        }
        try context.save()

        let history = try store.recommendationHistory()

        // 10 recent (20–29) + 10 capped helpful older (5–14, the 10 most recent of the 15 helpful)
        #expect(history.count == 20)
        let transcripts = history.map(\.transcript)
        #expect(transcripts.contains("full transcript 14"))
        #expect(transcripts.contains("full transcript 5"))
        #expect(!transcripts.contains("full transcript 4"))
    }

    @Test func recommendationHistorySelectsRecentPlusOlderHelpfulSessions() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = SwiftDataSessionStore(modelContext: context)

        for index in 0..<25 {
            let helpfulOlder = [2, 5, 13].contains(index)
            let helpfulRecent = index == 23
            context.insert(makeSession(
                index: index,
                wasHelpful: helpfulOlder || helpfulRecent,
                practiceName: helpfulOlder || helpfulRecent ? "Practice \(index)" : nil
            ))
        }
        try context.save()

        let history = try store.recommendationHistory()
        let transcripts = history.map(\.transcript)

        #expect(history.count == 13)
        #expect(transcripts == [
            "full transcript 24",
            "full transcript 23",
            "full transcript 22",
            "full transcript 21",
            "full transcript 20",
            "full transcript 19",
            "full transcript 18",
            "full transcript 17",
            "full transcript 16",
            "full transcript 15",
            "full transcript 13",
            "full transcript 5",
            "full transcript 2",
        ])
        #expect(!transcripts.contains("full transcript 14"))
        #expect(!transcripts.contains("full transcript 1"))
        #expect(Set(transcripts).count == transcripts.count)
        #expect(history.first { $0.transcript == "full transcript 13" }?.practiceName == "Practice 13")
        #expect(history.first { $0.transcript == "full transcript 13" }?.wasHelpful == true)
    }
}
