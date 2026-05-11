import Foundation
import AVFoundation
import Testing
@testable import sift

struct AudioRecorderServiceTests {

    private func makeService(
        session: FakeAudioSession = FakeAudioSession(),
        factory: FakeAudioRecorderFactory = FakeAudioRecorderFactory(),
        permission: FakePermissionRequester = FakePermissionRequester()
    ) -> AudioRecorderService {
        AudioRecorderService(session: session, recorderFactory: factory, permissionRequester: permission)
    }

    // MARK: - Initial state

    @Test func initialStateIsIdle() {
        let service = makeService()
        #expect(!service.isRecording)
        #expect(service.recordingDuration == 0)
        #expect(service.audioLevel == -160)
    }

    // MARK: - startRecording

    @Test func startRecordingConfiguresSessionAndStartsRecorder() throws {
        let session = FakeAudioSession()
        let factory = FakeAudioRecorderFactory()
        let service = makeService(session: session, factory: factory)

        _ = try service.startRecording()

        #expect(session.setCategoryCallCount == 1)
        #expect(session.setActiveCalls == [true])
        #expect(factory.recorder?.isMeteringEnabled == true)
        #expect(factory.recorder?.didRecord == true)
        #expect(service.isRecording == true)
    }

    @Test func startRecordingResetsObservableState() throws {
        let service = makeService()

        _ = try service.startRecording()

        #expect(service.recordingDuration == 0)
        #expect(service.audioLevel == -160)
    }

    @Test func startRecordingReturnsWavURL() throws {
        let service = makeService()
        let url = try service.startRecording()
        #expect(url.pathExtension == "wav")
    }

    @Test func startRecordingSessionCategoryFailurePropagates() {
        let session = FakeAudioSession()
        session.setCategoryError = testError("category failed")
        let service = makeService(session: session)

        #expect(throws: (any Error).self) {
            _ = try service.startRecording()
        }
        #expect(!service.isRecording)
    }

    @Test func startRecordingSessionActivationFailurePropagates() {
        let session = FakeAudioSession()
        session.setActiveError = testError("activation failed")
        let service = makeService(session: session)

        #expect(throws: (any Error).self) {
            _ = try service.startRecording()
        }
        #expect(!service.isRecording)
    }

    @Test func startRecordingRecorderCreationFailurePropagates() {
        let factory = FakeAudioRecorderFactory()
        factory.makeError = testError("recorder init failed")
        let service = makeService(factory: factory)

        #expect(throws: (any Error).self) {
            _ = try service.startRecording()
        }
        #expect(!service.isRecording)
    }

    // MARK: - stopRecording

    @Test func stopRecordingStopsRecorderAndDeactivatesSession() throws {
        let session = FakeAudioSession()
        let factory = FakeAudioRecorderFactory()
        let service = makeService(session: session, factory: factory)

        _ = try service.startRecording()
        service.stopRecording()

        #expect(factory.recorder?.didStop == true)
        #expect(!service.isRecording)
        #expect(session.setActiveCalls == [true, false])
    }

    @Test func stopRecordingWithoutStartingIsHarmless() {
        let service = makeService()
        service.stopRecording()
        #expect(!service.isRecording)
    }

    @Test func stopRecordingTwiceIsIdempotent() throws {
        let factory = FakeAudioRecorderFactory()
        let service = makeService(factory: factory)

        _ = try service.startRecording()
        service.stopRecording()
        service.stopRecording()

        #expect(!service.isRecording)
    }

    // MARK: - tickMeter

    @Test func tickMeterUpdatesDurationAndLevel() throws {
        let factory = FakeAudioRecorderFactory()
        let service = makeService(factory: factory)
        _ = try service.startRecording()

        let fakeRecorder = try #require(factory.recorder)
        fakeRecorder.currentTime = 3.7
        fakeRecorder.averagePowerValue = -20

        service.tickMeter()

        #expect(service.recordingDuration == 3.7)
        #expect(service.audioLevel == -20)
        #expect(fakeRecorder.updateMetersCallCount == 1)
    }

    @Test func tickMeterClampsLowAudioLevels() throws {
        let factory = FakeAudioRecorderFactory()
        let service = makeService(factory: factory)
        _ = try service.startRecording()

        let fakeRecorder = try #require(factory.recorder)
        fakeRecorder.averagePowerValue = -120

        service.tickMeter()

        #expect(service.audioLevel == -60)
    }

    @Test func tickMeterPassesThroughLevelsAboveFloor() throws {
        let factory = FakeAudioRecorderFactory()
        let service = makeService(factory: factory)
        _ = try service.startRecording()

        let fakeRecorder = try #require(factory.recorder)
        fakeRecorder.averagePowerValue = -10

        service.tickMeter()

        #expect(service.audioLevel == -10)
    }

    @Test func tickMeterDoesNothingWhenNotRecording() {
        let service = makeService()
        service.tickMeter()
        #expect(service.recordingDuration == 0)
        #expect(service.audioLevel == -160)
    }

    // MARK: - requestPermission

    @Test func requestPermissionGrantedReturnsTrue() async {
        let service = makeService(permission: FakePermissionRequester(granted: true))
        let result = await service.requestPermission()
        #expect(result == true)
    }

    @Test func requestPermissionDeniedReturnsFalse() async {
        let service = makeService(permission: FakePermissionRequester(granted: false))
        let result = await service.requestPermission()
        #expect(result == false)
    }
}

// MARK: - Fakes

private final class FakeAudioSession: AudioSessionConfiguring {
    var setCategoryCallCount = 0
    var setActiveCalls: [Bool] = []
    var setCategoryError: Error?
    var setActiveError: Error?

    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws {
        setCategoryCallCount += 1
        if let error = setCategoryError { throw error }
    }

    func setActive(_ active: Bool) throws {
        setActiveCalls.append(active)
        if let error = setActiveError { throw error }
    }
}

private final class FakeAudioRecorderFactory: AudioRecorderCreating {
    var recorder: FakeAudioRecorderController?
    var makeError: Error?

    func makeRecorder(url: URL, settings: [String: Any]) throws -> AudioRecorderControlling {
        if let error = makeError { throw error }
        let r = FakeAudioRecorderController()
        recorder = r
        return r
    }
}

private final class FakeAudioRecorderController: AudioRecorderControlling {
    var isMeteringEnabled = false
    var currentTime: TimeInterval = 0
    var averagePowerValue: Float = -30
    var didRecord = false
    var didStop = false
    var updateMetersCallCount = 0

    @discardableResult
    func record() -> Bool {
        didRecord = true
        return true
    }

    func stop() {
        didStop = true
    }

    func updateMeters() {
        updateMetersCallCount += 1
    }

    func averagePower(forChannel channelNumber: Int) -> Float {
        averagePowerValue
    }
}

private final class FakePermissionRequester: AudioPermissionRequesting {
    private let granted: Bool

    init(granted: Bool = true) {
        self.granted = granted
    }

    func requestPermission() async -> Bool {
        granted
    }
}

private func testError(_ message: String) -> NSError {
    NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
}
