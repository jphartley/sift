import Foundation
import SwiftUI
import SwiftData

enum RecordingState: Equatable {
    case idle
    case loadingModel
    case ready
    case recording
    case transcribing
    case analyzing
    case suggesting(transcript: String, practices: [Practice], rationale: String, wasEscalated: Bool, relevanceByID: [String: String])
    case reflecting(practiceName: String)
    case error(String)
}

@Observable
final class RecordingViewModel {
    var state: RecordingState = .idle
    var recordingDuration: TimeInterval = 0
    var audioLevel: Float = -160
    var lastTranscript: String = ""

    private let audioRecorder = AudioRecorderService()
    private var transcriptionService: TranscriptionService?
    private var geminiService: GeminiService?
    private var currentRecordingURL: URL?
    private var modelContext: ModelContext?
    private var pendingSession: Session?
    private var currentAttempt: PracticeAttempt?
    private var lastRecommendationResult: RecommendationResult?

    func configure(modelContext: ModelContext, transcriptionService: TranscriptionService, geminiService: GeminiService) {
        self.modelContext = modelContext
        self.transcriptionService = transcriptionService
        self.geminiService = geminiService
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

        do {
            currentRecordingURL = try audioRecorder.startRecording()
            state = .recording

            Task { @MainActor in
                while audioRecorder.isRecording {
                    recordingDuration = audioRecorder.recordingDuration
                    audioLevel = audioRecorder.audioLevel
                    try? await Task.sleep(for: .milliseconds(50))
                }
            }
        } catch {
            state = .error("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder.stopRecording()
        let audioDuration = recordingDuration
        state = .transcribing

        guard let recordingURL = currentRecordingURL else {
            state = .error("No recording found")
            return
        }

        guard let transcriptionService else {
            state = .error("Transcription service not configured")
            return
        }

        Task {
            do {
                let (text, transcriptionMs) = try await transcriptionService.transcribe(audioURL: recordingURL)

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

                pendingSession?.geminiRationale = result.rationale
                pendingSession?.geminiModelUsed = result.modelUsed
                pendingSession?.geminiConfidence = result.confidence
                lastRecommendationResult = result

                let practices = resolvePractices(from: result)
                var relevanceByID: [String: String] = [:]
                for (id, relevance) in result.practices {
                    relevanceByID[id] = relevance
                }

                state = .suggesting(
                    transcript: text,
                    practices: practices,
                    rationale: result.rationale,
                    wasEscalated: result.wasEscalated,
                    relevanceByID: relevanceByID
                )
            } catch {
                state = .error("Analyzing failed: \(error.localizedDescription)")
                print("[RecordingViewModel] Analysis failed in stopRecording: \(error)")
            }
        }
    }

    func logPractice(practiceID: String, practiceName: String) {
        guard let session = pendingSession else { return }
        let attempt = PracticeAttempt(practiceID: practiceID, practiceName: practiceName)
        session.attempts.append(attempt)
        currentAttempt = attempt
        state = .reflecting(practiceName: practiceName)
    }

    func completeReflection(wasHelpful: Bool?, notes: String?) {
        guard let context = modelContext,
              let session = pendingSession,
              let attempt = currentAttempt else { return }

        attempt.wasHelpful = wasHelpful
        attempt.notes = notes

        context.insert(session)
        try? context.save()

        pendingSession = nil
        currentAttempt = nil
        recordingDuration = 0
        audioLevel = -160
        state = .ready
    }

    func dismissPractice() {
        guard let session = pendingSession, let result = lastRecommendationResult else {
            state = .ready
            return
        }
        let practices = resolvePractices(from: result)
        currentAttempt = nil
        session.attempts.removeAll()
        var relevanceByID: [String: String] = [:]
        for (id, relevance) in result.practices {
            relevanceByID[id] = relevance
        }
        state = .suggesting(
            transcript: session.transcript,
            practices: practices,
            rationale: result.rationale,
            wasEscalated: result.wasEscalated,
            relevanceByID: relevanceByID
        )
    }

    func skipSuggestions() {
        guard let context = modelContext, let session = pendingSession else {
            state = .ready
            return
        }

        context.insert(session)
        try? context.save()

        pendingSession = nil
        currentAttempt = nil
        recordingDuration = 0
        audioLevel = -160
        state = .ready
    }

    func retryAnalysis() {
        guard let session = pendingSession else {
            state = .ready
            return
        }
        let transcript = session.transcript
        state = .analyzing
        Task {
            do {
                let result = try await analyzeAndSuggest(transcript: transcript)

                pendingSession?.geminiRationale = result.rationale
                pendingSession?.geminiModelUsed = result.modelUsed
                pendingSession?.geminiConfidence = result.confidence
                lastRecommendationResult = result

                let practices = resolvePractices(from: result)
                var relevanceByID: [String: String] = [:]
                for (id, relevance) in result.practices {
                    relevanceByID[id] = relevance
                }

                state = .suggesting(
                    transcript: transcript,
                    practices: practices,
                    rationale: result.rationale,
                    wasEscalated: result.wasEscalated,
                    relevanceByID: relevanceByID
                )
            } catch {
                state = .error("Analyzing failed: \(error.localizedDescription)")
                print("[RecordingViewModel] Analysis failed in retryAnalysis: \(error)")
            }
        }
    }

    private func analyzeAndSuggest(transcript: String) async throws -> RecommendationResult {
        guard let geminiService else {
            throw GeminiError.apiKeyMissing
        }

        let history = buildHistoryPayload()
        return try await geminiService.recommend(transcript: transcript, history: history)
    }

    private func buildHistoryPayload() -> [SessionHistoryEntry] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        let sessions = (try? context.fetch(descriptor)) ?? []

        return sessions.map { session in
            let attempt = session.attempts.first
            return SessionHistoryEntry(
                timestamp: session.timestamp,
                transcript: session.transcript,
                practiceName: attempt?.practiceName,
                wasHelpful: attempt?.wasHelpful
            )
        }
    }

    private func resolvePractices(from result: RecommendationResult) -> [Practice] {
        let allPractices = Dictionary(uniqueKeysWithValues: Practice.all.map { ($0.id, $0) })
        return result.practices.compactMap { allPractices[$0.practiceID] }
    }
}
