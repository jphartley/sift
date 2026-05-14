import Testing
import AVFoundation
@testable import sift

private final class FakeAVAudioRecorder: AVAudioRecorderProtocol {
    let capturedURL: URL
    let capturedSettings: [String: Any]
    var isMeteringEnabled = false
    var currentTime: TimeInterval = 0
    var didCallRecord = false
    var didCallStop = false

    init(url: URL, settings: [String: Any]) {
        self.capturedURL = url
        self.capturedSettings = settings
    }

    @discardableResult func record() -> Bool { didCallRecord = true; return true }
    func stop() { didCallStop = true }
    func updateMeters() {}
    func averagePower(forChannel channelNumber: Int) -> Float { -160 }
}

private final class FakeAudioRecorderFactory: AudioRecorderFactory {
    private(set) var lastRecorder: FakeAVAudioRecorder?

    func makeRecorder(url: URL, settings: [String: Any]) throws -> AVAudioRecorderProtocol {
        let recorder = FakeAVAudioRecorder(url: url, settings: settings)
        lastRecorder = recorder
        return recorder
    }
}

@Suite("AudioRecorderService")
struct AudioRecorderServiceTests {

    @Test func defaultsToNotRecording() {
        let service = AudioRecorderService()
        #expect(service.isRecording == false)
    }

    @Test func defaultAudioLevel() {
        let service = AudioRecorderService()
        #expect(service.audioLevel == -160)
    }

    @Test func defaultRecordingDuration() {
        let service = AudioRecorderService()
        #expect(service.recordingDuration == 0)
    }

    @Test func stopRecordingOnIdleInstanceDoesNotCrash() {
        let service = AudioRecorderService()
        service.stopRecording()
        #expect(service.isRecording == false)
    }

    @Test func startRecordingSetsIsRecording() throws {
        let factory = FakeAudioRecorderFactory()
        let service = AudioRecorderService(recorderFactory: factory)
        _ = try service.startRecording()
        #expect(service.isRecording == true)
    }

    @Test func startRecordingReturnsWavURL() throws {
        let factory = FakeAudioRecorderFactory()
        let service = AudioRecorderService(recorderFactory: factory)
        let url = try service.startRecording()
        #expect(url.pathExtension == "wav")
    }

    @Test func startRecordingUsesPCMFormat() throws {
        let factory = FakeAudioRecorderFactory()
        let service = AudioRecorderService(recorderFactory: factory)
        _ = try service.startRecording()
        let formatID = factory.lastRecorder?.capturedSettings[AVFormatIDKey] as? Int
        #expect(formatID == Int(kAudioFormatLinearPCM))
    }

    @Test func startRecordingUses16kHzSampleRate() throws {
        let factory = FakeAudioRecorderFactory()
        let service = AudioRecorderService(recorderFactory: factory)
        _ = try service.startRecording()
        let sampleRate = factory.lastRecorder?.capturedSettings[AVSampleRateKey] as? Double
        #expect(sampleRate == 16000.0)
    }

    @Test func startRecordingUsesMonoChannel() throws {
        let factory = FakeAudioRecorderFactory()
        let service = AudioRecorderService(recorderFactory: factory)
        _ = try service.startRecording()
        let channels = factory.lastRecorder?.capturedSettings[AVNumberOfChannelsKey] as? Int
        #expect(channels == 1)
    }

    @Test func startRecordingEnablesMetering() throws {
        let factory = FakeAudioRecorderFactory()
        let service = AudioRecorderService(recorderFactory: factory)
        _ = try service.startRecording()
        #expect(factory.lastRecorder?.isMeteringEnabled == true)
    }

    @Test func stopRecordingAfterStartResetsIsRecording() throws {
        let factory = FakeAudioRecorderFactory()
        let service = AudioRecorderService(recorderFactory: factory)
        _ = try service.startRecording()
        service.stopRecording()
        #expect(service.isRecording == false)
    }
}
