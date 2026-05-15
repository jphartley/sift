import Foundation

enum RecordingState: Equatable {
    case idle
    case loadingModel
    case ready
    case preparingToRecord
    case recording
    case transcribing
    case analyzing
    case suggesting(transcript: String, practices: [Practice], rationale: String, wasEscalated: Bool, relevanceByID: [String: String])
    case practicing(practice: Practice, relevance: String)
    case reflecting(practiceName: String)
    case recovery(CheckInRecoveryPresentation)
    case error(String)
}

@Observable
final class RecordingViewModel {
    var state: RecordingState = .idle
    var recordingDuration: TimeInterval = 0
    var audioLevel: Float = -160
    var lastTranscript: String = ""

    private var audioRecorder: AudioRecording
    private var transcriptionService: TranscriptionClient?
    private var recommendationClient: RecommendationClient?
    private var sessionStore: SessionStore?
    private var meterPollingTask: Task<Void, Never>?
    private var recordingStartupTask: Task<Void, Never>?
    private var analysisTask: Task<Void, Never>?
    private var analysisTaskID: UUID?
    private var currentRecordingURL: URL?
    var pendingSession: Session?
    var currentAttempt: PracticeAttempt?
    var lastRecommendationResult: RecommendationResult?

    init(audioRecorder: AudioRecording = AudioRecorderService()) {
        self.audioRecorder = audioRecorder
    }

    func configure(
        sessionStore: SessionStore,
        transcriptionService: TranscriptionClient,
        recommendationClient: RecommendationClient,
        audioRecorder: AudioRecording? = nil
    ) {
        self.sessionStore = sessionStore
        self.transcriptionService = transcriptionService
        self.recommendationClient = recommendationClient
        if let audioRecorder {
            self.audioRecorder = audioRecorder
        }
    }

    func setup() async {
        state = .loadingModel

        let hasPermission = await audioRecorder.requestPermission()
        guard hasPermission else {
            state = .recovery(.microphonePermissionDenied)
            return
        }

        state = .ready
    }

    @discardableResult
    func startRecording() -> Task<Void, Never>? {
        guard case .ready = state else { return nil }
        cancelMeterPolling()
        state = .preparingToRecord

        let task = Task { @MainActor in
            let hasPermission = await audioRecorder.requestPermission()
            guard !Task.isCancelled else {
                recordingStartupTask = nil
                return
            }
            guard case .preparingToRecord = state else {
                recordingStartupTask = nil
                return
            }
            guard hasPermission else {
                cancelMeterPolling()
                recordingStartupTask = nil
                state = .recovery(.microphonePermissionDenied)
                return
            }

            do {
                currentRecordingURL = try audioRecorder.startRecording()
                state = .recording
                startMeterPolling()
            } catch {
                cancelMeterPolling()
                state = .recovery(.emptySpeech)
            }

            recordingStartupTask = nil
        }
        recordingStartupTask = task
        return task
    }

    @discardableResult
    func stopRecording() -> Task<Void, Never>? {
        audioRecorder.stopRecording()
        cancelMeterPolling()
        let audioDuration = recordingDuration
        state = .transcribing

        guard let recordingURL = currentRecordingURL else {
            state = .recovery(.emptySpeech)
            return nil
        }

        guard let transcriptionService else {
            state = .recovery(.modelLoadingFailed)
            return nil
        }

        let taskID = replaceAnalysisTaskID()
        let task = Task { @MainActor in
            do {
                let (text, transcriptionMs) = try await transcriptionService.transcribe(audioURL: recordingURL)
                guard !Task.isCancelled, analysisTaskID == taskID else { return }
                let transcript = text.trimmingCharacters(in: .whitespacesAndNewlines)

                try? FileManager.default.removeItem(at: recordingURL)
                currentRecordingURL = nil

                guard !transcript.isEmpty else {
                    lastTranscript = ""
                    pendingSession = nil
                    state = .recovery(.emptySpeech)
                    return
                }

                lastTranscript = transcript

                pendingSession = Session(
                    timestamp: Date(),
                    transcript: transcript,
                    audioDuration: audioDuration,
                    transcriptionDurationMs: transcriptionMs
                )

                state = .analyzing

                let result = try await analyzeAndSuggest(transcript: transcript)
                guard !Task.isCancelled, analysisTaskID == taskID else { return }

                try applyRecommendationResult(result, transcript: transcript)
            } catch GeminiError.emptyPractices {
                guard !Task.isCancelled, analysisTaskID == taskID else { return }
                state = .recovery(.emptySuggestions)
            } catch {
                guard !Task.isCancelled, analysisTaskID == taskID else { return }
                state = pendingSession == nil ? .recovery(.emptySpeech) : .recovery(.analysisFailed)
            }

            if analysisTaskID == taskID {
                analysisTask = nil
                analysisTaskID = nil
            }
        }
        analysisTask = task
        return task
    }

    func selectPractice(practice: Practice, relevance: String?) {
        state = .practicing(practice: practice, relevance: relevance ?? "")
    }

    func completeSelectedPractice() {
        guard let session = pendingSession else { return }
        guard case .practicing(let practice, _) = state else { return }
        let attempt = PracticeAttempt(practiceID: practice.id, practiceName: practice.name)
        session.attempts.append(attempt)
        currentAttempt = attempt
        state = .reflecting(practiceName: practice.name)
    }

    func completeReflection(wasHelpful: Bool?, notes: String?) {
        guard let session = pendingSession,
              let attempt = currentAttempt else { return }

        attempt.wasHelpful = wasHelpful
        attempt.notes = notes

        saveAndReset(session)
    }

    func dismissPractice() {
        guard let session = pendingSession, let result = lastRecommendationResult else {
            state = .ready
            return
        }
        let practices = resolvePractices(from: result)
        guard !practices.isEmpty else {
            state = .recovery(.emptySuggestions)
            return
        }
        currentAttempt = nil
        session.attempts.removeAll()
        state = .suggesting(
            transcript: session.transcript,
            practices: practices,
            rationale: result.rationale,
            wasEscalated: result.wasEscalated,
            relevanceByID: relevanceByID(from: result)
        )
    }

    func skipSuggestions() {
        guard let session = pendingSession else {
            state = .ready
            return
        }

        saveAndReset(session)
    }

    @discardableResult
    func retryAnalysis() -> Task<Void, Never>? {
        guard let session = pendingSession else {
            state = .ready
            return nil
        }
        let transcript = session.transcript
        state = .analyzing
        let taskID = replaceAnalysisTaskID()
        let task = Task { @MainActor in
            do {
                let result = try await analyzeAndSuggest(transcript: transcript)
                guard !Task.isCancelled, analysisTaskID == taskID else { return }

                try applyRecommendationResult(result, transcript: transcript)
            } catch GeminiError.emptyPractices {
                guard !Task.isCancelled, analysisTaskID == taskID else { return }
                state = .recovery(.emptySuggestions)
            } catch {
                guard !Task.isCancelled, analysisTaskID == taskID else { return }
                state = .recovery(.analysisFailed)
            }

            if analysisTaskID == taskID {
                analysisTask = nil
                analysisTaskID = nil
            }
        }
        analysisTask = task
        return task
    }

    func tearDown() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
        }
        recordingStartupTask?.cancel()
        recordingStartupTask = nil
        cancelMeterPolling()
        cancelAnalysisTask()
    }

    func retryPermission() -> Task<Void, Never> {
        Task { @MainActor in
            await setup()
        }
    }

    func recordAgain() {
        pendingSession = nil
        currentAttempt = nil
        currentRecordingURL = nil
        recordingDuration = 0
        audioLevel = -160
        state = .ready
    }

    func retrySave() {
        guard let session = pendingSession else {
            state = .ready
            return
        }
        saveAndReset(session)
    }

    private func analyzeAndSuggest(transcript: String) async throws -> RecommendationResult {
        guard let recommendationClient else {
            throw GeminiError.apiKeyMissing
        }

        let history = try sessionStore?.recommendationHistory() ?? []
        return try await recommendationClient.recommend(transcript: transcript, history: history)
    }

    private func resolvePractices(from result: RecommendationResult) -> [Practice] {
        let allPractices = Dictionary(uniqueKeysWithValues: Practice.all.map { ($0.id, $0) })
        return result.practices.compactMap { allPractices[$0.practiceID] }
    }

    private func applyRecommendationResult(_ result: RecommendationResult, transcript: String) throws {
        pendingSession?.geminiRationale = result.rationale
        pendingSession?.geminiModelUsed = result.modelUsed
        pendingSession?.geminiConfidence = result.confidence
        lastRecommendationResult = result

        let practices = resolvePractices(from: result)
        guard !practices.isEmpty else {
            throw GeminiError.emptyPractices
        }

        state = .suggesting(
            transcript: transcript,
            practices: practices,
            rationale: result.rationale,
            wasEscalated: result.wasEscalated,
            relevanceByID: relevanceByID(from: result)
        )
    }

    private func relevanceByID(from result: RecommendationResult) -> [String: String] {
        var relevance: [String: String] = [:]
        for practice in result.practices {
            relevance[practice.practiceID] = practice.relevance
        }
        return relevance
    }

    private func saveAndReset(_ session: Session) {
        guard let sessionStore else {
            state = .recovery(.saveFailed)
            return
        }

        do {
            try sessionStore.save(session)
            resetAfterSave()
        } catch {
            state = .recovery(.saveFailed)
        }
    }

    private func resetAfterSave() {
        pendingSession = nil
        currentAttempt = nil
        recordingDuration = 0
        audioLevel = -160
        state = .ready
    }

    private func startMeterPolling() {
        cancelMeterPolling()
        meterPollingTask = Task { @MainActor in
            while !Task.isCancelled && audioRecorder.isRecording {
                recordingDuration = audioRecorder.recordingDuration
                audioLevel = audioRecorder.audioLevel
                do {
                    try await Task.sleep(for: .milliseconds(50))
                } catch {
                    break
                }
            }
        }
    }

    private func cancelMeterPolling() {
        meterPollingTask?.cancel()
        meterPollingTask = nil
    }

    private func replaceAnalysisTaskID() -> UUID {
        cancelAnalysisTask()
        let taskID = UUID()
        analysisTaskID = taskID
        return taskID
    }

    private func cancelAnalysisTask() {
        analysisTask?.cancel()
        analysisTask = nil
        analysisTaskID = nil
    }
}
