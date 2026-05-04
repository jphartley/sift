import Foundation
import SwiftUI
import SwiftData

enum RecordingState: Equatable {
    case idle
    case loadingModel
    case ready
    case recording
    case transcribing
    case suggesting(transcript: String, practices: [Practice])
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
    private let transcriptionService = TranscriptionService()
    private var currentRecordingURL: URL?
    private var modelContext: ModelContext?
    private var pendingSession: Session?
    private var currentAttempt: PracticeAttempt?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func setup() async {
        guard transcriptionService.modelState == .notLoaded else { return }
        state = .loadingModel

        let hasPermission = await audioRecorder.requestPermission()
        guard hasPermission else {
            state = .error("Microphone access denied. Enable it in Settings.")
            return
        }

        await transcriptionService.loadModel()

        switch transcriptionService.modelState {
        case .ready:
            state = .ready
        case .failed(let message):
            state = .error(message)
        default:
            break
        }
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

                let suggestions = await suggestPractices(for: text)
                state = .suggesting(transcript: text, practices: suggestions)
            } catch {
                state = .error("Transcription failed: \(error.localizedDescription)")
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
        guard let session = pendingSession else {
            state = .ready
            return
        }
        let suggestions = rankPractices(for: session.transcript)
        currentAttempt = nil
        session.attempts.removeAll()
        state = .suggesting(transcript: session.transcript, practices: suggestions)
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

    private func suggestPractices(for transcript: String) async -> [Practice] {
        let ranked = rankPractices(for: transcript)
        return Array(ranked.prefix(3))
    }

    private func rankPractices(for transcript: String) -> [Practice] {
        let matches = Practice.match(transcript: transcript)
        let helpfulIDs = previouslyHelpfulIDs()

        var scored = matches.map { match -> (Practice, Int) in
            let bonus = helpfulIDs.contains(match.practice.id) ? 2 : 0
            return (match.practice, match.score + bonus)
        }
        scored.sort { $0.1 > $1.1 }

        return scored.map(\.0)
    }

    private func previouslyHelpfulIDs() -> Set<String> {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<PracticeAttempt>(
            predicate: #Predicate { $0.wasHelpful == true },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let helpful = (try? context.fetch(descriptor)) ?? []
        return Set(helpful.map(\.practiceID))
    }
}
