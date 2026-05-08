import Foundation
import WhisperKit

enum ModelState: Equatable {
    case notLoaded
    case downloading(progress: Double)
    case loading
    case ready
    case failed(String)
}

@Observable
final class TranscriptionService: TranscriptionClient {
    private var whisperKit: WhisperKit?
    var modelState: ModelState = .notLoaded

    func loadModel() async {
        if case .downloading = modelState { return }
        if case .loading = modelState { return }
        if case .ready = modelState { return }

        modelState = .downloading(progress: 0)

        do {
            let modelFolder = try await WhisperKit.download(
                variant: "openai_whisper-base.en",
                progressCallback: { [weak self] progress in
                    self?.modelState = .downloading(progress: progress.fractionCompleted)
                }
            )

            modelState = .loading

            whisperKit = try await WhisperKit(
                modelFolder: modelFolder.path,
                download: false
            )

            modelState = .ready
        } catch {
            modelState = .failed(error.localizedDescription)
        }
    }

    func transcribe(audioURL: URL) async throws -> (text: String, durationMs: Int) {
        guard let whisperKit else {
            throw TranscriptionError.modelNotLoaded
        }

        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw TranscriptionError.fileNotFound
        }

        let startTime = Date()
        let results = try await whisperKit.transcribe(audioPath: audioURL.path)
        let duration = Int(Date().timeIntervalSince(startTime) * 1000)

        let text = results.map(\.text).joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (text, duration)
    }
}

enum TranscriptionError: LocalizedError {
    case modelNotLoaded
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded: return "Speech model not loaded"
        case .fileNotFound: return "Audio file not found"
        }
    }
}
