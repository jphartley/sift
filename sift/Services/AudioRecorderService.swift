import Foundation
import AVFoundation

protocol AudioSessionConfiguring: AnyObject {
    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws
    func setActive(_ active: Bool) throws
}

protocol AudioRecorderControlling: AnyObject {
    var isMeteringEnabled: Bool { get set }
    var currentTime: TimeInterval { get }
    @discardableResult func record() -> Bool
    func stop()
    func updateMeters()
    func averagePower(forChannel channelNumber: Int) -> Float
}

protocol AudioRecorderCreating {
    func makeRecorder(url: URL, settings: [String: Any]) throws -> AudioRecorderControlling
}

protocol AudioPermissionRequesting {
    func requestPermission() async -> Bool
}

extension AVAudioSession: AudioSessionConfiguring {}
extension AVAudioRecorder: AudioRecorderControlling {}

final class DefaultAudioRecorderFactory: AudioRecorderCreating {
    func makeRecorder(url: URL, settings: [String: Any]) throws -> AudioRecorderControlling {
        try AVAudioRecorder(url: url, settings: settings)
    }
}

final class AVAudioApplicationPermissionRequester: AudioPermissionRequesting {
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                continuation.resume(returning: true)
            case .denied:
                continuation.resume(returning: false)
            case .undetermined:
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            @unknown default:
                continuation.resume(returning: false)
            }
        }
    }
}

@Observable
final class AudioRecorderService: AudioRecording {
    private let session: AudioSessionConfiguring
    private let recorderFactory: AudioRecorderCreating
    private let permissionRequester: AudioPermissionRequesting

    private var recorder: AudioRecorderControlling?
    private var timer: Timer?
    var isRecording = false
    var recordingDuration: TimeInterval = 0
    var audioLevel: Float = -160

    init(
        session: AudioSessionConfiguring = AVAudioSession.sharedInstance(),
        recorderFactory: AudioRecorderCreating = DefaultAudioRecorderFactory(),
        permissionRequester: AudioPermissionRequesting = AVAudioApplicationPermissionRequester()
    ) {
        self.session = session
        self.recorderFactory = recorderFactory
        self.permissionRequester = permissionRequester
    }

    func requestPermission() async -> Bool {
        await permissionRequester.requestPermission()
    }

    func startRecording() throws -> URL {
        try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).wav")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder = try recorderFactory.makeRecorder(url: url, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.record()

        self.recorder = recorder
        isRecording = true
        recordingDuration = 0
        audioLevel = -160

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tickMeter()
        }

        return url
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false

        timer?.invalidate()
        timer = nil

        try? session.setActive(false)
    }

    func tickMeter() {
        guard let recorder else { return }
        recorder.updateMeters()
        recordingDuration = recorder.currentTime
        let level = recorder.averagePower(forChannel: 0)
        audioLevel = max(-60, level)
    }
}
