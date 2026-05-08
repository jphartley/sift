import Foundation

enum RecordingState: Equatable {
    case idle
    case loadingModel
    case ready
    case recording
    case transcribing
    case analyzing
    case suggesting(transcript: String, practices: [Practice], rationale: String, wasEscalated: Bool, relevanceByID: [String: String])
    case reflecting(practiceName: String, practiceDescription: String, relevance: String)
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
        recommendationClient: RecommendationClient
    ) {
        self.sessionStore = sessionStore
        self.transcriptionService = transcriptionService
        self.recommendationClient = recommendationClient
    }

    func setup() async {
        state = .loadingModel

        let hasPermission = await audioRecorder.requestPermission()
        guard hasPermission else {
            state = .error("Microphone access denied. Enable it in Settings.")
            return
        }

        state = .ready
    }

    func startRecording() {
        guard case .ready = state else { return }
        cancelMeterPolling()

        do {
            currentRecordingURL = try audioRecorder.startRecording()
            state = .recording
            startMeterPolling()
        } catch {
            cancelMeterPolling()
            state = .error("Failed to start recording: \(error.localizedDescription)")
        }
    }

    @discardableResult
    func stopRecording() -> Task<Void, Never>? {
        audioRecorder.stopRecording()
        cancelMeterPolling()
        let audioDuration = recordingDuration
        state = .transcribing

        guard let recordingURL = currentRecordingURL else {
            state = .error("No recording found")
            return nil
        }

        guard let transcriptionService else {
            state = .error("Transcription service not configured")
            return nil
        }

        let taskID = replaceAnalysisTaskID()
        let task = Task { @MainActor in
            do {
                let (text, transcriptionMs) = try await transcriptionService.transcribe(audioURL: recordingURL)
                guard !Task.isCancelled, analysisTaskID == taskID else { return }

                try? FileManager.default.removeItem(at: recordingURL)
                currentRecordingURL = nil

                lastTranscript = text

                pendingSession = Session(
                    timestamp: Date(),
                    transcript: text,
                    audioDuration: audioDuration,
                    transcriptionDurationMs: transcriptionMs
                )

                state = .analyzing

                let result = try await analyzeAndSuggest(transcript: text)
                guard !Task.isCancelled, analysisTaskID == taskID else { return }

                try applyRecommendationResult(result, transcript: text)
            } catch {
                guard !Task.isCancelled, analysisTaskID == taskID else { return }
                state = .error("Analyzing failed: \(error.localizedDescription)")
            }

            if analysisTaskID == taskID {
                analysisTask = nil
                analysisTaskID = nil
            }
        }
        analysisTask = task
        return task
    }

    func logPractice(practice: Practice, relevance: String?) {
        guard let session = pendingSession else { return }
        let attempt = PracticeAttempt(practiceID: practice.id, practiceName: practice.name)
        session.attempts.append(attempt)
        currentAttempt = attempt
        state = .reflecting(
            practiceName: practice.name,
            practiceDescription: practice.description,
            relevance: relevance ?? ""
        )
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
            state = .error(GeminiError.emptyPractices.localizedDescription)
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
            } catch {
                guard !Task.isCancelled, analysisTaskID == taskID else { return }
                state = .error("Analyzing failed: \(error.localizedDescription)")
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
        cancelMeterPolling()
        cancelAnalysisTask()
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
            state = .error("Session store not configured")
            return
        }

        do {
            try sessionStore.save(session)
            resetAfterSave()
        } catch {
            state = .error("Saving failed: \(error.localizedDescription)")
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
