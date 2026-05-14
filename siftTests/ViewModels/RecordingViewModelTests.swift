import Foundation
import Testing
@testable import sift

@MainActor
struct RecordingViewModelTests {

    init() {
        TestHelpers.setupPractices()
    }

    private func makeViewModel(
        audioRecorder: FakeAudioRecorder? = nil,
        transcriptionClient: FakeTranscriptionClient? = nil,
        recommendationClient: RecommendationClient? = nil,
        sessionStore: FakeSessionStore? = nil
    ) -> (RecordingViewModel, FakeAudioRecorder, FakeTranscriptionClient, RecommendationClient, FakeSessionStore) {
        let audioRecorder = audioRecorder ?? FakeAudioRecorder()
        let transcriptionClient = transcriptionClient ?? FakeTranscriptionClient()
        let recommendationClient = recommendationClient ?? FakeRecommendationClient()
        let sessionStore = sessionStore ?? FakeSessionStore()
        let viewModel = RecordingViewModel(audioRecorder: audioRecorder)
        viewModel.configure(
            sessionStore: sessionStore,
            transcriptionService: transcriptionClient,
            recommendationClient: recommendationClient
        )
        return (viewModel, audioRecorder, transcriptionClient, recommendationClient, sessionStore)
    }

    private func startRecording(_ viewModel: RecordingViewModel) async {
        if let task = viewModel.startRecording() {
            await task.value
        }
    }

    @Test func setupRequestsPermissionAndBecomesReady() async {
        let (viewModel, audioRecorder, _, _, _) = makeViewModel()

        await viewModel.setup()

        #expect(audioRecorder.didRequestPermission)
        #expect(viewModel.state == .ready)
    }

    @Test func setupPermissionDeniedShowsError() async {
        let audioRecorder = FakeAudioRecorder(permissionGranted: false)
        let (viewModel, _, _, _, _) = makeViewModel(audioRecorder: audioRecorder)

        await viewModel.setup()

        #expect(viewModel.state == .recovery(.microphonePermissionDenied))
    }

    @Test func retryPermissionRequestsPermissionAgain() async {
        let audioRecorder = FakeAudioRecorder(permissionGranted: true)
        let (viewModel, _, _, _, _) = makeViewModel(audioRecorder: audioRecorder)
        viewModel.state = .recovery(.microphonePermissionDenied)

        let task = viewModel.retryPermission()
        await task.value

        #expect(audioRecorder.permissionRequestCount == 1)
        #expect(viewModel.state == .ready)
    }

    @Test func startRecordingImmediatelyShowsPreparingState() async {
        let audioRecorder = FakeAudioRecorder(permissionDelay: .milliseconds(50))
        let (viewModel, _, _, _, _) = makeViewModel(audioRecorder: audioRecorder)
        viewModel.state = .ready

        let task = viewModel.startRecording()

        #expect(viewModel.state == .preparingToRecord)

        await task?.value

        #expect(viewModel.state == .recording)
        #expect(audioRecorder.startRecordingCount == 1)
    }

    @Test func repeatedStartRecordingWhilePreparingDoesNotOverlapStartup() async {
        let audioRecorder = FakeAudioRecorder(permissionDelay: .milliseconds(50))
        let (viewModel, _, _, _, _) = makeViewModel(audioRecorder: audioRecorder)
        viewModel.state = .ready

        let firstTask = viewModel.startRecording()
        let secondTask = viewModel.startRecording()

        #expect(secondTask == nil)
        #expect(viewModel.state == .preparingToRecord)

        await firstTask?.value

        #expect(audioRecorder.permissionRequestCount == 1)
        #expect(audioRecorder.startRecordingCount == 1)
        #expect(viewModel.state == .recording)
    }

    @Test func permissionDeniedDuringRecordingStartupShowsRecovery() async {
        let audioRecorder = FakeAudioRecorder(permissionGranted: false, permissionDelay: .milliseconds(10))
        let (viewModel, _, _, _, _) = makeViewModel(audioRecorder: audioRecorder)
        viewModel.state = .ready

        let task = viewModel.startRecording()

        #expect(viewModel.state == .preparingToRecord)

        await task?.value

        #expect(viewModel.state == .recovery(.microphonePermissionDenied))
        #expect(audioRecorder.startRecordingCount == 0)
    }

    @Test func stopRecordingTranscribesAndShowsSuggestions() async {
        let transcriptionClient = FakeTranscriptionClient(text: "I feel anxious", durationMs: 123)
        let recommendationClient = FakeRecommendationClient(result: RecommendationResult(
            rationale: "Breathing can help with anxiety.",
            practices: [(practiceID: "box-breathing", relevance: "A structured breath can settle your nervous system.")],
            confidence: 0.9,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ))
        let (viewModel, _, _, _, _) = makeViewModel(
            transcriptionClient: transcriptionClient,
            recommendationClient: recommendationClient
        )
        viewModel.state = .ready
        viewModel.recordingDuration = 4.2

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        #expect(transcriptionClient.transcribedURL != nil)
        #expect(recommendationClient.receivedTranscript == "I feel anxious")
        #expect(viewModel.lastTranscript == "I feel anxious")
        #expect(viewModel.pendingSession?.transcript == "I feel anxious")
        #expect(viewModel.pendingSession?.audioDuration == 4.2)
        #expect(viewModel.pendingSession?.transcriptionDurationMs == 123)
        #expect(viewModel.pendingSession?.geminiRationale == "Breathing can help with anxiety.")
        #expect(viewModel.pendingSession?.geminiModelUsed == "gemini-3-flash-preview")
        #expect(viewModel.pendingSession?.geminiConfidence == 0.9)

        guard case .suggesting(let transcript, let practices, let rationale, let wasEscalated, let relevanceByID) = viewModel.state else {
            #expect(Bool(false), "Expected .suggesting state")
            return
        }

        #expect(transcript == "I feel anxious")
        #expect(practices.map(\.id) == ["box-breathing"])
        #expect(rationale == "Breathing can help with anxiety.")
        #expect(wasEscalated == false)
        #expect(relevanceByID["box-breathing"] == "A structured breath can settle your nervous system.")
    }

    @Test func recommendationFailureKeepsPendingTranscriptForRetry() async {
        let recommendationClient = FakeRecommendationClient(error: GeminiError.networkError("offline"))
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.state = .ready

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        guard case .recovery(let presentation) = viewModel.state else {
            #expect(Bool(false), "Expected .recovery state")
            return
        }

        #expect(presentation == .analysisFailed)
        #expect(viewModel.pendingSession?.transcript == "I feel anxious")
        #expect(viewModel.lastTranscript == "I feel anxious")
    }

    @Test func emptySpeechShowsRecordAgainRecoveryAndSkipsRecommendation() async {
        let transcriptionClient = FakeTranscriptionClient(text: "   \n", durationMs: 25)
        let recommendationClient = FakeRecommendationClient()
        let (viewModel, _, _, _, _) = makeViewModel(
            transcriptionClient: transcriptionClient,
            recommendationClient: recommendationClient
        )
        viewModel.state = .ready

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        #expect(viewModel.state == .recovery(.emptySpeech))
        #expect(recommendationClient.receivedTranscript == nil)
        #expect(viewModel.pendingSession == nil)

        viewModel.recordAgain()

        #expect(viewModel.state == .ready)
    }

    @Test func retryAnalysisUsesPendingSession() async {
        let recommendationClient = FakeRecommendationClient(result: RecommendationResult(
            rationale: "Try moving gently.",
            practices: [(practiceID: "stretch-break", relevance: "Stretching can help stiffness.")],
            confidence: 0.8,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ))
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.pendingSession = Session(transcript: "My shoulders are stiff")

        if let task = viewModel.retryAnalysis() {
            await task.value
        }

        #expect(recommendationClient.receivedTranscript == "My shoulders are stiff")
        guard case .suggesting(_, let practices, let rationale, _, _) = viewModel.state else {
            #expect(Bool(false), "Expected .suggesting state")
            return
        }
        #expect(practices.map(\.id) == ["stretch-break"])
        #expect(rationale == "Try moving gently.")
    }

    @Test func retryAfterAnalysisFailureReusesPendingTranscript() async {
        let recommendationClient = SequencedRecommendationClient(results: [
            .failure(GeminiError.networkError("offline")),
            .success(RecommendationResult(
                rationale: "Try breathing.",
                practices: [(practiceID: "box-breathing", relevance: "Breathing can help.")],
                confidence: 0.9,
                modelUsed: "gemini-3-flash-preview",
                wasEscalated: false
            ))
        ])
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.state = .ready

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        #expect(viewModel.state == .recovery(.analysisFailed))
        #expect(viewModel.pendingSession?.transcript == "I feel anxious")

        if let retryTask = viewModel.retryAnalysis() {
            await retryTask.value
        }

        #expect(recommendationClient.receivedTranscripts == ["I feel anxious", "I feel anxious"])
        guard case .suggesting(let transcript, let practices, _, _, _) = viewModel.state else {
            #expect(Bool(false), "Expected .suggesting state")
            return
        }
        #expect(transcript == "I feel anxious")
        #expect(practices.map(\.id) == ["box-breathing"])
    }

    @Test func meterPollingStopsUpdatingAfterStopRecording() async {
        let audioRecorder = FakeAudioRecorder(keepsRecordingAfterStop: true)
        let (viewModel, _, _, _, _) = makeViewModel(audioRecorder: audioRecorder)
        viewModel.state = .ready

        await startRecording(viewModel)
        try? await Task.sleep(for: .milliseconds(70))
        #expect(viewModel.recordingDuration == 4.2)

        _ = viewModel.stopRecording()
        audioRecorder.recordingDuration = 99
        audioRecorder.audioLevel = -1
        try? await Task.sleep(for: .milliseconds(120))

        #expect(viewModel.recordingDuration == 4.2)
        #expect(viewModel.audioLevel == -24)
    }

    @Test func retryAnalysisIgnoresEarlierInFlightResult() async {
        let recommendationClient = ControlledRecommendationClient()
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.pendingSession = Session(transcript: "I feel tense")

        let firstTask = viewModel.retryAnalysis()
        await recommendationClient.waitForRequestCount(1)

        let secondTask = viewModel.retryAnalysis()
        await recommendationClient.waitForRequestCount(2)

        recommendationClient.resumeRequest(at: 1, with: RecommendationResult(
            rationale: "Second result",
            practices: [(practiceID: "stretch-break", relevance: "Move gently.")],
            confidence: 0.9,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ))
        await secondTask?.value

        recommendationClient.resumeRequest(at: 0, with: RecommendationResult(
            rationale: "First result",
            practices: [(practiceID: "box-breathing", relevance: "Breathe slowly.")],
            confidence: 0.9,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ))
        await firstTask?.value

        guard case .suggesting(_, let practices, let rationale, _, _) = viewModel.state else {
            #expect(Bool(false), "Expected .suggesting state")
            return
        }

        #expect(rationale == "Second result")
        #expect(practices.map { $0.id } == ["stretch-break"])
    }

    @Test func tearDownDuringAnalysisPreventsSuggestionsAndCancellationError() async {
        let recommendationClient = ControlledRecommendationClient()
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.pendingSession = Session(transcript: "I feel tense")

        let task = viewModel.retryAnalysis()
        await recommendationClient.waitForRequestCount(1)

        viewModel.tearDown()
        recommendationClient.resumeRequest(at: 0, with: RecommendationResult(
            rationale: "Late result",
            practices: [(practiceID: "box-breathing", relevance: "Breathe slowly.")],
            confidence: 0.9,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ))
        await task?.value

        #expect(viewModel.state == RecordingState.analyzing)
        #expect(viewModel.lastRecommendationResult == nil)
    }

    @Test func tearDownDuringRecordingStopsRecorderAndCancelsMeterPolling() async {
        let audioRecorder = FakeAudioRecorder(keepsRecordingAfterStop: true)
        let (viewModel, _, _, _, _) = makeViewModel(audioRecorder: audioRecorder)
        viewModel.state = .ready

        await startRecording(viewModel)
        try? await Task.sleep(for: .milliseconds(70))
        #expect(viewModel.recordingDuration == 4.2)

        viewModel.tearDown()
        audioRecorder.recordingDuration = 99
        audioRecorder.audioLevel = -1
        try? await Task.sleep(for: .milliseconds(120))

        #expect(audioRecorder.didStopRecording)
        #expect(viewModel.recordingDuration == 4.2)
        #expect(viewModel.audioLevel == -24)
    }

    @Test func selectPracticeOpensPracticeDetailWithoutLoggingAttempt() {
        let (viewModel, _, _, _, _) = makeViewModel()

        guard let practice = Practice.all.first(where: { $0.id == "box-breathing" }) else {
            #expect(Bool(false), "Practice not found")
            return
        }

        viewModel.pendingSession = Session(transcript: "I feel anxious")
        viewModel.selectPractice(practice: practice, relevance: "Breathing helps regulate your nervous system")

        guard case .practicing(let selectedPractice, let relevance) = viewModel.state else {
            #expect(Bool(false), "Expected .practicing state")
            return
        }
        #expect(selectedPractice == practice)
        #expect(relevance == "Breathing helps regulate your nervous system")
        #expect(viewModel.pendingSession?.attempts.isEmpty == true)
        #expect(viewModel.currentAttempt == nil)
    }

    @Test func selectPracticeWithNilRelevanceUsesEmptyString() {
        let (viewModel, _, _, _, _) = makeViewModel()

        guard let practice = Practice.all.first(where: { $0.id == "stretch-break" }) else {
            #expect(Bool(false), "Practice not found")
            return
        }

        viewModel.pendingSession = Session(transcript: "test")
        viewModel.selectPractice(practice: practice, relevance: nil)

        guard case .practicing(_, let relevance) = viewModel.state else {
            #expect(Bool(false), "Expected .practicing state")
            return
        }
        #expect(relevance == "")
    }

    @Test func completeSelectedPracticeLogsAttemptAndOpensReflection() {
        let (viewModel, _, _, _, _) = makeViewModel()

        guard let practice = Practice.all.first(where: { $0.id == "box-breathing" }) else {
            #expect(Bool(false), "Practice not found")
            return
        }

        viewModel.pendingSession = Session(transcript: "I feel anxious")
        viewModel.selectPractice(practice: practice, relevance: "Breathing helps")
        viewModel.completeSelectedPractice()

        guard case .reflecting(let name) = viewModel.state else {
            #expect(Bool(false), "Expected .reflecting state")
            return
        }
        #expect(name == "Box Breathing")
        #expect(viewModel.pendingSession?.attempts.count == 1)
        #expect(viewModel.currentAttempt?.practiceID == "box-breathing")
        #expect(viewModel.currentAttempt?.wasHelpful == nil)
    }

    @Test func completeSelectedPracticeDoesNothingOutsidePracticeDetail() {
        let (viewModel, _, _, _, _) = makeViewModel()
        viewModel.pendingSession = Session(transcript: "I feel anxious")
        viewModel.state = .suggesting(transcript: "I feel anxious", practices: [], rationale: "", wasEscalated: false, relevanceByID: [:])

        viewModel.completeSelectedPractice()

        #expect(viewModel.pendingSession?.attempts.isEmpty == true)
        #expect(viewModel.currentAttempt == nil)
    }

    @Test func completeReflectionSavesSessionAndResetsState() {
        let sessionStore = FakeSessionStore()
        let (viewModel, _, _, _, _) = makeViewModel(sessionStore: sessionStore)
        let session = Session(transcript: "I feel tired")
        let attempt = PracticeAttempt(practiceID: "body-scan", practiceName: "Body Scan")
        session.attempts.append(attempt)
        viewModel.pendingSession = session
        viewModel.currentAttempt = attempt
        viewModel.recordingDuration = 5
        viewModel.audioLevel = -20

        viewModel.completeReflection(wasHelpful: true, notes: "felt calmer")

        #expect(sessionStore.savedSessions.count == 1)
        #expect(sessionStore.savedSessions[0].transcript == "I feel tired")
        #expect(sessionStore.savedSessions[0].attempts.count == 1)
        #expect(sessionStore.savedSessions[0].attempts[0].wasHelpful == true)
        #expect(sessionStore.savedSessions[0].attempts[0].notes == "felt calmer")
        #expect(viewModel.pendingSession == nil)
        #expect(viewModel.currentAttempt == nil)
        #expect(viewModel.recordingDuration == 0)
        #expect(viewModel.audioLevel == -160)
        #expect(viewModel.state == .ready)
    }

    @Test func skipSuggestionsSavesEmptySessionAndResetsState() {
        let sessionStore = FakeSessionStore()
        let (viewModel, _, _, _, _) = makeViewModel(sessionStore: sessionStore)
        viewModel.pendingSession = Session(transcript: "test")
        viewModel.recordingDuration = 3
        viewModel.audioLevel = -30

        viewModel.skipSuggestions()

        #expect(sessionStore.savedSessions.count == 1)
        #expect(sessionStore.savedSessions[0].transcript == "test")
        #expect(sessionStore.savedSessions[0].attempts.isEmpty)
        #expect(viewModel.pendingSession == nil)
        #expect(viewModel.state == .ready)
        #expect(viewModel.recordingDuration == 0)
        #expect(viewModel.audioLevel == -160)
    }

    @Test func saveFailureDoesNotSilentlyReset() {
        let sessionStore = FakeSessionStore(saveError: TestError.saveFailed)
        let (viewModel, _, _, _, _) = makeViewModel(sessionStore: sessionStore)
        let session = Session(transcript: "I feel tired")
        let attempt = PracticeAttempt(practiceID: "body-scan", practiceName: "Body Scan")
        session.attempts.append(attempt)
        viewModel.pendingSession = session
        viewModel.currentAttempt = attempt

        viewModel.completeReflection(wasHelpful: false, notes: nil)

        guard case .recovery(let presentation) = viewModel.state else {
            #expect(Bool(false), "Expected .recovery state")
            return
        }
        #expect(presentation == .saveFailed)
        #expect(sessionStore.savedSessions.isEmpty)
        #expect(viewModel.pendingSession === session)
        #expect(viewModel.currentAttempt === attempt)
    }

    @Test func saveFailureCanRetrySaveWithReflectionData() {
        let sessionStore = FakeSessionStore(saveError: TestError.saveFailed)
        let (viewModel, _, _, _, _) = makeViewModel(sessionStore: sessionStore)
        let session = Session(transcript: "I feel tired")
        let attempt = PracticeAttempt(practiceID: "body-scan", practiceName: "Body Scan")
        session.attempts.append(attempt)
        viewModel.pendingSession = session
        viewModel.currentAttempt = attempt

        viewModel.completeReflection(wasHelpful: false, notes: "still tense")

        sessionStore.saveError = nil
        viewModel.retrySave()

        #expect(sessionStore.savedSessions.count == 1)
        #expect(sessionStore.savedSessions[0].attempts[0].wasHelpful == false)
        #expect(sessionStore.savedSessions[0].attempts[0].notes == "still tense")
        #expect(viewModel.state == .ready)
    }

    @Test func historyFromStoreIsPassedToRecommendationClient() async {
        let history = [
            SessionHistoryEntry(
                timestamp: Date(timeIntervalSince1970: 100),
                transcript: "Yesterday was stressful",
                practiceName: "Box Breathing",
                wasHelpful: true
            )
        ]
        let sessionStore = FakeSessionStore(history: history)
        let recommendationClient = FakeRecommendationClient()
        let (viewModel, _, _, _, _) = makeViewModel(
            recommendationClient: recommendationClient,
            sessionStore: sessionStore
        )
        viewModel.state = .ready

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        #expect(recommendationClient.receivedHistory.count == 1)
        #expect(recommendationClient.receivedHistory[0].transcript == "Yesterday was stressful")
        #expect(recommendationClient.receivedHistory[0].practiceName == "Box Breathing")
        #expect(recommendationClient.receivedHistory[0].wasHelpful == true)
    }

    @Test func noResolvablePracticesShowsEmptySuggestionsRecovery() async {
        let recommendationClient = FakeRecommendationClient(result: RecommendationResult(
            rationale: "Try something.",
            practices: [(practiceID: "missing-practice", relevance: "Not in the library.")],
            confidence: 0.8,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ))
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.state = .ready

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        guard case .recovery(let presentation) = viewModel.state else {
            #expect(Bool(false), "Expected .recovery state")
            return
        }
        #expect(presentation == .emptySuggestions)
        #expect(viewModel.pendingSession?.transcript == "I feel anxious")
    }

    @Test func partiallyResolvablePracticesDropsBogusIds() async {
        let recommendationClient = FakeRecommendationClient(result: RecommendationResult(
            rationale: "Try these.",
            practices: [
                (practiceID: "box-breathing", relevance: "Grounding."),
                (practiceID: "nonexistent-practice", relevance: "Not in library.")
            ],
            confidence: 0.8,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ))
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.state = .ready

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        guard case .suggesting(_, let practices, _, _, _) = viewModel.state else {
            #expect(Bool(false), "Expected .suggesting state")
            return
        }
        #expect(practices.count == 1)
        #expect(practices[0].id == "box-breathing")
    }

    @Test func retryAfterEmptySuggestionsReusesPendingTranscript() async {
        let recommendationClient = SequencedRecommendationClient(results: [
            .success(RecommendationResult(
                rationale: "Try something.",
                practices: [(practiceID: "missing-practice", relevance: "Not in the library.")],
                confidence: 0.8,
                modelUsed: "gemini-3-flash-preview",
                wasEscalated: false
            )),
            .success(RecommendationResult(
                rationale: "Try breathing.",
                practices: [(practiceID: "box-breathing", relevance: "Breathing can help.")],
                confidence: 0.9,
                modelUsed: "gemini-3-flash-preview",
                wasEscalated: false
            ))
        ])
        let (viewModel, _, _, _, _) = makeViewModel(recommendationClient: recommendationClient)
        viewModel.state = .ready

        await startRecording(viewModel)
        if let task = viewModel.stopRecording() {
            await task.value
        }

        #expect(viewModel.state == .recovery(.emptySuggestions))

        if let retryTask = viewModel.retryAnalysis() {
            await retryTask.value
        }

        #expect(recommendationClient.receivedTranscripts == ["I feel anxious", "I feel anxious"])
        guard case .suggesting(let transcript, let practices, let rationale, _, _) = viewModel.state else {
            #expect(Bool(false), "Expected .suggesting state")
            return
        }
        #expect(transcript == "I feel anxious")
        #expect(practices.map(\.id) == ["box-breathing"])
        #expect(rationale == "Try breathing.")
    }

    @Test func dismissPracticeReturnsToSuggestingWithOriginalDataWithoutLoggingAttempt() {
        let (viewModel, _, _, _, _) = makeViewModel()
        let result = RecommendationResult(
            rationale: "Test rationale",
            practices: [(practiceID: "box-breathing", relevance: "Helps with anxiety")],
            confidence: 0.9,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        )
        let session = Session(transcript: "I feel anxious")
        viewModel.pendingSession = session
        viewModel.lastRecommendationResult = result
        viewModel.selectPractice(practice: Practice.all[0], relevance: "Helps with anxiety")

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

    @Test func skipReflectionPersistsCompletedAttemptWithNilHelpfulness() {
        let sessionStore = FakeSessionStore()
        let (viewModel, _, _, _, _) = makeViewModel(sessionStore: sessionStore)

        guard let practice = Practice.all.first(where: { $0.id == "box-breathing" }) else {
            #expect(Bool(false), "Practice not found")
            return
        }

        viewModel.pendingSession = Session(transcript: "I feel anxious")
        viewModel.selectPractice(practice: practice, relevance: "Breathing helps")
        viewModel.completeSelectedPractice()

        viewModel.completeReflection(wasHelpful: nil, notes: nil)

        #expect(sessionStore.savedSessions.count == 1)
        #expect(sessionStore.savedSessions[0].attempts.count == 1)
        #expect(sessionStore.savedSessions[0].attempts[0].practiceID == "box-breathing")
        #expect(sessionStore.savedSessions[0].attempts[0].wasHelpful == nil)
        #expect(sessionStore.savedSessions[0].attempts[0].notes == nil)
        #expect(viewModel.state == .ready)
    }
}

private final class FakeAudioRecorder: AudioRecording {
    var isRecording = false
    var recordingDuration: TimeInterval
    var audioLevel: Float
    var didRequestPermission = false
    var permissionRequestCount = 0
    var didStartRecording = false
    var startRecordingCount = 0
    var didStopRecording = false

    private let permissionGranted: Bool
    private let permissionDelay: Duration?
    private let recordingURL: URL
    private let startError: Error?
    private let keepsRecordingAfterStop: Bool

    init(
        permissionGranted: Bool = true,
        recordingDuration: TimeInterval = 4.2,
        audioLevel: Float = -24,
        permissionDelay: Duration? = nil,
        recordingURL: URL = URL(fileURLWithPath: "/tmp/fake-recording.wav"),
        startError: Error? = nil,
        keepsRecordingAfterStop: Bool = false
    ) {
        self.permissionGranted = permissionGranted
        self.permissionDelay = permissionDelay
        self.recordingDuration = recordingDuration
        self.audioLevel = audioLevel
        self.recordingURL = recordingURL
        self.startError = startError
        self.keepsRecordingAfterStop = keepsRecordingAfterStop
    }

    func requestPermission() async -> Bool {
        didRequestPermission = true
        permissionRequestCount += 1
        if let permissionDelay {
            try? await Task.sleep(for: permissionDelay)
        }
        return permissionGranted
    }

    func startRecording() throws -> URL {
        didStartRecording = true
        startRecordingCount += 1
        if let startError { throw startError }
        isRecording = true
        return recordingURL
    }

    func stopRecording() {
        didStopRecording = true
        if !keepsRecordingAfterStop {
            isRecording = false
        }
    }
}

private final class FakeTranscriptionClient: TranscriptionClient {
    var modelState: ModelState = .ready
    var transcribedURL: URL?

    private let text: String
    private let durationMs: Int
    private let error: Error?

    init(text: String = "I feel anxious", durationMs: Int = 100, error: Error? = nil) {
        self.text = text
        self.durationMs = durationMs
        self.error = error
    }

    func transcribe(audioURL: URL) async throws -> (text: String, durationMs: Int) {
        if let error { throw error }
        transcribedURL = audioURL
        return (text, durationMs)
    }
}

private final class FakeRecommendationClient: RecommendationClient {
    var receivedTranscript: String?
    var receivedHistory: [SessionHistoryEntry] = []

    private let result: RecommendationResult
    private let error: Error?

    init(
        result: RecommendationResult = RecommendationResult(
            rationale: "Try box breathing.",
            practices: [(practiceID: "box-breathing", relevance: "It can help with anxiety.")],
            confidence: 0.9,
            modelUsed: "gemini-3-flash-preview",
            wasEscalated: false
        ),
        error: Error? = nil
    ) {
        self.result = result
        self.error = error
    }

    func recommend(transcript: String, history: [SessionHistoryEntry]) async throws -> RecommendationResult {
        if let error { throw error }
        receivedTranscript = transcript
        receivedHistory = history
        return result
    }
}

private final class ControlledRecommendationClient: RecommendationClient {
    private var requests: [CheckedContinuation<RecommendationResult, Error>] = []

    func recommend(transcript: String, history: [SessionHistoryEntry]) async throws -> RecommendationResult {
        try await withCheckedThrowingContinuation { continuation in
            requests.append(continuation)
        }
    }

    func waitForRequestCount(_ count: Int) async {
        while requests.count < count {
            await Task.yield()
        }
    }

    func resumeRequest(at index: Int, with result: RecommendationResult) {
        requests[index].resume(returning: result)
    }
}

private final class SequencedRecommendationClient: RecommendationClient {
    var receivedTranscripts: [String] = []
    private var results: [Result<RecommendationResult, Error>]

    init(results: [Result<RecommendationResult, Error>]) {
        self.results = results
    }

    func recommend(transcript: String, history: [SessionHistoryEntry]) async throws -> RecommendationResult {
        receivedTranscripts.append(transcript)
        guard !results.isEmpty else {
            throw TestError.noMoreResults
        }
        return try results.removeFirst().get()
    }
}

private final class FakeSessionStore: SessionStore {
    var savedSessions: [Session] = []
    var deletedSessions: [Session] = []
    var history: [SessionHistoryEntry]

    var saveError: Error?
    private let deleteError: Error?
    private let historyError: Error?

    init(
        history: [SessionHistoryEntry] = [],
        saveError: Error? = nil,
        deleteError: Error? = nil,
        historyError: Error? = nil
    ) {
        self.history = history
        self.saveError = saveError
        self.deleteError = deleteError
        self.historyError = historyError
    }

    func recommendationHistory() throws -> [SessionHistoryEntry] {
        if let historyError { throw historyError }
        return history
    }

    func save(_ session: Session) throws {
        if let saveError { throw saveError }
        savedSessions.append(session)
    }

    func delete(_ sessions: [Session]) throws {
        if let deleteError { throw deleteError }
        deletedSessions.append(contentsOf: sessions)
    }
}

private enum TestError: LocalizedError {
    case saveFailed
    case noMoreResults

    var errorDescription: String? {
        switch self {
        case .saveFailed: "save failed"
        case .noMoreResults: "no more results"
        }
    }
}
