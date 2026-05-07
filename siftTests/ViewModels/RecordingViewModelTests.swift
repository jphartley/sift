import Foundation
import SwiftData
import Testing
@testable import sift

@MainActor
struct RecordingViewModelTests {

    init() {
        TestHelpers.setupPractices()
    }

    private func makeViewModel() throws -> (RecordingViewModel, ModelContainer, TranscriptionService, GeminiService) {
        let container = try TestHelpers.makeContainer()
        let transcriptionService = TranscriptionService()
        let geminiService = GeminiService()
        let viewModel = RecordingViewModel()
        viewModel.configure(modelContext: container.mainContext, transcriptionService: transcriptionService, geminiService: geminiService)
        return (viewModel, container, transcriptionService, geminiService)
    }

    @Test func completeReflectionPersistsSessionAndResetsState() throws {
        let (viewModel, container, _, _) = try makeViewModel()
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
        let (viewModel, container, _, _) = try makeViewModel()
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
        let (_, container, _, _) = try makeViewModel()
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
        let (_, container, _, _) = try makeViewModel()
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

    @Test func setupDoesNotTriggerModelLoad() async throws {
        let (viewModel, _, transcriptionService, _) = try makeViewModel()
        transcriptionService.modelState = .ready

        await viewModel.setup()

        #expect(transcriptionService.modelState == .ready)
    }

    @Test func configureSetsAllServices() throws {
        let container = try TestHelpers.makeContainer()
        let transcriptionService = TranscriptionService()
        let geminiService = GeminiService()
        let viewModel = RecordingViewModel()

        viewModel.configure(
            modelContext: container.mainContext,
            transcriptionService: transcriptionService,
            geminiService: geminiService
        )

        #expect(viewModel.state == .idle)
    }

    @Test func analyzingStateEquality() async {
        #expect(RecordingState.analyzing == RecordingState.analyzing)
    }

    @Test func suggestingWithGeminiDataIsNotIdle() async {
        let state = RecordingState.suggesting(
            transcript: "test",
            practices: [],
            rationale: "reason",
            wasEscalated: false,
            relevanceByID: [:]
        )
        #expect(state != RecordingState.idle)
    }

    @Test func logPracticeSetsReflectingWithDescriptionAndRelevance() throws {
        let (viewModel, _, _, _) = try makeViewModel()

        guard let practice = Practice.all.first(where: { $0.id == "box-breathing" }) else {
            #expect(Bool(false), "Practice not found")
            return
        }

        viewModel.pendingSession = Session(transcript: "I feel anxious")
        viewModel.logPractice(practice: practice, relevance: "Breathing helps regulate your nervous system")

        guard case .reflecting(let name, let desc, let rel) = viewModel.state else {
            #expect(Bool(false), "Expected .reflecting state")
            return
        }
        #expect(name == "Box Breathing")
        #expect(desc == practice.description)
        #expect(rel == "Breathing helps regulate your nervous system")
    }

    @Test func logPracticeWithNilRelevanceUsesEmptyString() throws {
        let (viewModel, _, _, _) = try makeViewModel()

        guard let practice = Practice.all.first(where: { $0.id == "stretch-break" }) else {
            #expect(Bool(false), "Practice not found")
            return
        }

        viewModel.pendingSession = Session(transcript: "test")
        viewModel.logPractice(practice: practice, relevance: nil)

        guard case .reflecting(_, _, let rel) = viewModel.state else {
            #expect(Bool(false), "Expected .reflecting state")
            return
        }
        #expect(rel == "")
    }

    @Test func dismissPracticeReturnsToSuggestingWithOriginalData() throws {
        let (viewModel, _, _, _) = try makeViewModel()

        let result = RecommendationResult(
            rationale: "Test rationale",
            practices: [(practiceID: "box-breathing", relevance: "Helps with anxiety")],
            confidence: 0.9,
            modelUsed: "gemini-2.5-flash",
            wasEscalated: false
        )

        let session = Session(transcript: "I feel anxious")
        session.geminiRationale = result.rationale

        viewModel.pendingSession = session
        viewModel.lastRecommendationResult = result
        viewModel.dismissPractice()

        guard case .suggesting(let transcript, let practices, let rationale, let wasEscalated, let relevanceByID) = viewModel.state else {
            #expect(Bool(false), "Expected .suggesting state")
            return
        }
        #expect(transcript == "I feel anxious")
        #expect(rationale == "Test rationale")
        #expect(wasEscalated == false)
        #expect(practices.count == 1)
        #expect(practices[0].id == "box-breathing")
        #expect(relevanceByID["box-breathing"] == "Helps with anxiety")
        #expect(session.attempts.isEmpty)
    }

    @Test func reflectingEquality() async {
        let a = RecordingState.reflecting(practiceName: "A", practiceDescription: "Desc A", relevance: "Rel A")
        let b = RecordingState.reflecting(practiceName: "A", practiceDescription: "Desc A", relevance: "Rel A")
        #expect(a == b)
    }
}
