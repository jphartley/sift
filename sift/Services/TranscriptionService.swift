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
    static let modelVariant = "openai_whisper-base.en"

    private var whisperKit: WhisperKit?
    var modelState: ModelState = .notLoaded
    private let recorder: MetricRecorder?

    init(recorder: MetricRecorder? = nil) {
        self.recorder = recorder
    }

    func loadModel() async {
        if case .downloading = modelState { return }
        if case .loading = modelState { return }
        if case .ready = modelState { return }

        modelState = .downloading(progress: 0)

        do {
            let variantMetadata = ["variant": Self.modelVariant]
            let modelFolder = try await timed(name: "whisper.download", metadata: variantMetadata) {
                try await WhisperKit.download(
                    variant: Self.modelVariant,
                    progressCallback: { [weak self] progress in
                        self?.modelState = .downloading(progress: progress.fractionCompleted)
                    }
                )
            }

            modelState = .loading

            whisperKit = try await timed(name: "whisper.modelLoad", metadata: variantMetadata) {
                try await WhisperKit(
                    modelFolder: modelFolder.path,
                    download: false
                )
            }

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
        recorder?.record(name: "whisper.transcribe", durationMs: duration, metadata: ["variant": Self.modelVariant])

        let text = results.map(\.text).joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (text, duration)
    }

    private func timed<T>(name: String, metadata: [String: String]?, _ block: () async throws -> T) async throws -> T {
        if let recorder {
            return try await recorder.time(name: name, metadata: metadata, block)
        }
        return try await block()
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
