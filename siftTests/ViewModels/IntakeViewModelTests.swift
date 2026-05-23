import Foundation
import Testing
@testable import sift

@MainActor
struct IntakeViewModelTests {

    private func makeViewModel(
        recorder: FakeIntakeAudioRecorder = FakeIntakeAudioRecorder(),
        transcriptionClient: TranscriptionClient? = nil,
        screenIdleController: ScreenIdleControlling = FakeScreenIdleController()
    ) -> (IntakeViewModel, FakeIntakeAudioRecorder, ScreenIdleControlling) {
        let viewModel = IntakeViewModel(screenIdleController: screenIdleController)
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: transcriptionClient,
            audioRecorder: recorder
        )
        return (viewModel, recorder, screenIdleController)
    }

    @Test func noPreferenceIsMutuallyExclusive() {
        let viewModel = IntakeViewModel()
        let prompt = IntakeCopy.primaryPrompts[2]

        viewModel.toggleChip("secular-only", for: prompt)
        viewModel.toggleChip("spiritual-language-okay", for: prompt)
        viewModel.toggleChip("no-preference", for: prompt)

        #expect(viewModel.response(for: .boundaries).selectedChipIDs == ["no-preference"])

        viewModel.toggleChip("research-backed-only", for: prompt)

        #expect(viewModel.response(for: .boundaries).selectedChipIDs == ["research-backed-only"])
    }

    @Test func skipBehaviorPersistsSkippedProfile() {
        let store = FakeProfileStore()
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store)

        viewModel.skipIntake()

        #expect(store.didMarkSkipped)
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func skippedRestartSkipPersistsSkippedProfile() {
        let store = FakeProfileStore(savedProfile: .skipped())
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, mode: .restartFromSkipped)

        viewModel.skipIntake()

        #expect(store.didMarkSkipped)
        #expect(store.savedProfile?.completionState == .skipped)
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func skippedRestartContinueWithoutAnalysisPersistsSkippedProfile() {
        let store = FakeProfileStore(savedProfile: .skipped())
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, mode: .restartFromSkipped)

        viewModel.continueWithoutAnalysis()

        #expect(store.didMarkSkipped)
        #expect(store.savedProfile?.completionState == .skipped)
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func completedRestartSkipPreservesExistingProfile() throws {
        let existing = UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["Existing support"]
        )
        let store = FakeProfileStore(savedProfile: existing)
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, mode: .restartFromCompleted)

        viewModel.skipIntake()

        #expect(!store.didMarkSkipped)
        let saved = try #require(store.savedProfile)
        #expect(saved === existing)
        #expect(saved.desiredSupportAreas == ["Existing support"])
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func completedRestartContinueWithoutAnalysisPreservesExistingProfile() throws {
        let existing = UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["Existing support"]
        )
        let store = FakeProfileStore(savedProfile: existing)
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, mode: .restartFromCompleted)

        viewModel.continueWithoutAnalysis()

        #expect(!store.didMarkSkipped)
        let saved = try #require(store.savedProfile)
        #expect(saved === existing)
        #expect(saved.desiredSupportAreas == ["Existing support"])
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func completedRestartAbandonPreservesExistingProfile() throws {
        let existing = UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["Existing support"]
        )
        let store = FakeProfileStore(savedProfile: existing)
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, mode: .restartFromCompleted)

        viewModel.begin()
        viewModel.nextPrimary()
        viewModel.tearDown()

        #expect(!store.didMarkSkipped)
        let saved = try #require(store.savedProfile)
        #expect(saved === existing)
        #expect(!viewModel.didFinish)
    }

    @Test func completedRestartSuccessfulAnalysisReplacesExistingProfile() async throws {
        let existing = UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["Existing support"]
        )
        let store = FakeProfileStore(savedProfile: existing)
        let analyzer = FakeIntakeAnalyzer(result: UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["New support"]
        ))
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, mode: .restartFromCompleted, analyzer: analyzer)

        let task = viewModel.declineOptionalTuning()
        await task.value

        let saved = try #require(store.savedProfile)
        #expect(saved !== existing)
        #expect(saved.completionState == .completed)
        #expect(saved.desiredSupportAreas == ["New support"])
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func completedRestartAnalysisFailureThenContinuePreservesExistingProfile() async throws {
        let existing = UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["Existing support"]
        )
        let store = FakeProfileStore(savedProfile: existing)
        let analyzer = FakeIntakeAnalyzer(error: IntakeAnalysisError.failed)
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, mode: .restartFromCompleted, analyzer: analyzer)

        let task = viewModel.declineOptionalTuning()
        await task.value
        viewModel.continueWithoutAnalysis()

        #expect(!store.didMarkSkipped)
        let saved = try #require(store.savedProfile)
        #expect(saved === existing)
        #expect(saved.desiredSupportAreas == ["Existing support"])
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func completedIntakePersistsAnalyzedProfile() async {
        let store = FakeProfileStore()
        let analyzer = FakeIntakeAnalyzer(result: UserPracticeProfile(
            completionState: .completed,
            desiredSupportAreas: ["Calming down"]
        ))
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, analyzer: analyzer)

        viewModel.begin()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        let task = viewModel.declineOptionalTuning()
        await task.value

        #expect(store.savedProfile?.completionState == .completed)
        #expect(store.savedProfile?.desiredSupportAreas == ["Calming down"])
        #expect(viewModel.didFinish)
        #expect(viewModel.step == .complete)
    }

    @Test func optionalBranchAcceptanceSavesCompletedOptionalState() async {
        let store = FakeProfileStore()
        let analyzer = FakeIntakeAnalyzer(result: UserPracticeProfile(
            completionState: .completed,
            optionalTuningCompleted: true
        ))
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, analyzer: analyzer)

        viewModel.begin()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.acceptOptionalTuning()

        #expect(viewModel.step == .optional(0))

        _ = viewModel.nextOptional()
        _ = viewModel.nextOptional()
        _ = viewModel.nextOptional()
        let task = viewModel.nextOptional()
        await task?.value

        #expect(store.savedProfile?.optionalTuningCompleted == true)
        #expect(viewModel.step == .complete)
    }

    @Test func optionalBranchDeclineProceedsImmediatelyToCheckIn() async {
        let store = FakeProfileStore()
        let analyzer = FakeIntakeAnalyzer(result: UserPracticeProfile(completionState: .completed))
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, analyzer: analyzer)

        viewModel.begin()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        let task = viewModel.declineOptionalTuning()
        await task.value

        #expect(store.savedProfile?.optionalTuningCompleted == false)
        #expect(viewModel.didFinish)
    }

    @Test func failedAnalysisShowsRecoverableError() async {
        let store = FakeProfileStore()
        let analyzer = FakeIntakeAnalyzer(error: IntakeAnalysisError.failed)
        let viewModel = IntakeViewModel()
        viewModel.configure(profileStore: store, analyzer: analyzer)

        let task = viewModel.declineOptionalTuning()
        await task.value

        #expect(viewModel.step == .error("Sift could not save that context yet."))
        #expect(!viewModel.didFinish)
    }

    // MARK: - B1: per-practice sentiment bottom sheet

    @Test func priorPracticeChipSelectionDoesNotAutoAssignSentiment() {
        let viewModel = IntakeViewModel()
        viewModel.selectPracticeFamily("meditation")

        let response = viewModel.response(for: .priorPractice)
        #expect(response.selectedChipIDs.contains("meditation"))
        #expect(response.practiceSignals["meditation"] == nil)
    }

    @Test func selectingPracticeFamilyOpensSentimentSheet() {
        let viewModel = IntakeViewModel()
        viewModel.selectPracticeFamily("breathwork")

        #expect(viewModel.sentimentSheetPracticeID == "breathwork")
    }

    @Test func presentSentimentSheetForAlreadySelectedPractice() {
        let viewModel = IntakeViewModel()
        viewModel.selectPracticeFamily("journaling")
        viewModel.dismissSentimentSheet()

        viewModel.presentSentimentSheet(for: "journaling")
        #expect(viewModel.sentimentSheetPracticeID == "journaling")
    }

    @Test func setPracticeSignalAssignsSentimentAndDismissesSheet() {
        let viewModel = IntakeViewModel()
        viewModel.selectPracticeFamily("meditation")

        viewModel.setPracticeSignal(.workedForMe, for: "meditation")

        let response = viewModel.response(for: .priorPractice)
        #expect(response.practiceSignals["meditation"] == .workedForMe)
        #expect(viewModel.sentimentSheetPracticeID == nil)
    }

    @Test func clearPracticeSignalRemovesSentimentButKeepsSelection() {
        let viewModel = IntakeViewModel()
        viewModel.selectPracticeFamily("yoga-or-movement")
        viewModel.setPracticeSignal(.helpedSometimes, for: "yoga-or-movement")

        viewModel.clearPracticeSignal(for: "yoga-or-movement")

        let response = viewModel.response(for: .priorPractice)
        #expect(response.selectedChipIDs.contains("yoga-or-movement"))
        #expect(response.practiceSignals["yoga-or-movement"] == nil)
    }

    @Test func removePracticeFamilyClearsBothSelectionAndSentiment() {
        let viewModel = IntakeViewModel()
        viewModel.selectPracticeFamily("meditation")
        viewModel.setPracticeSignal(.workedForMe, for: "meditation")

        viewModel.removePracticeFamily("meditation")

        let response = viewModel.response(for: .priorPractice)
        #expect(!response.selectedChipIDs.contains("meditation"))
        #expect(response.practiceSignals["meditation"] == nil)
        #expect(viewModel.sentimentSheetPracticeID == nil)
    }

    // MARK: - B2: transcription gating

    @Test func stopVoiceAnswerSetsIsTranscribingUntilSuccess() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        let stopTask = viewModel.stopVoiceAnswer()
        #expect(viewModel.isTranscribing)

        client.finish(text: "I want calm.")
        await stopTask?.value

        #expect(!viewModel.isTranscribing)
        #expect(viewModel.response(for: .desiredSupport).voiceTranscript == "I want calm.")
        #expect(viewModel.transcriptionError == nil)
    }

    @Test func startVoiceAnswerEnablesScreenAwakeAfterRecorderStartupSucceeds() async {
        let (viewModel, _, screenIdleController) = makeViewModel()

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value

        let fakeIdle = screenIdleController as? FakeScreenIdleController
        #expect(fakeIdle?.calls == [true])
        #expect(fakeIdle?.isIdleTimerDisabled == true)
        #expect(viewModel.isRecordingVoiceAnswer)
    }

    @Test func stopVoiceAnswerRestoresScreenIdleBehaviorBeforeTranscriptionCompletes() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let screenIdleController = FakeScreenIdleController()
        let viewModel = IntakeViewModel(screenIdleController: screenIdleController)
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        let stopTask = viewModel.stopVoiceAnswer()

        let fakeIdle = screenIdleController as? FakeScreenIdleController
        #expect(viewModel.isTranscribing)
        #expect(fakeIdle?.isIdleTimerDisabled == false)

        client.finish(text: "I want calm.")
        await stopTask?.value

        #expect(fakeIdle?.calls == [true, false])
        #expect(fakeIdle?.isIdleTimerDisabled == false)
    }

    @Test func skipCurrentPromptStopsActiveRecordingAndRestoresScreenIdleBehavior() async {
        let recorder = FakeIntakeAudioRecorder()
        let screenIdleController = FakeScreenIdleController()
        let viewModel = IntakeViewModel(screenIdleController: screenIdleController)
        viewModel.configure(
            profileStore: FakeProfileStore(),
            audioRecorder: recorder
        )

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        #expect(viewModel.isRecordingVoiceAnswer)

        viewModel.skipCurrentPrompt()

        let fakeIdle = screenIdleController as? FakeScreenIdleController
        #expect(!viewModel.isRecordingVoiceAnswer)
        #expect(!viewModel.isTranscribing)
        #expect(recorder.didStopRecording)
        #expect(fakeIdle?.isIdleTimerDisabled == false)
        #expect(fakeIdle?.calls == [true, false])
    }

    @Test func tearDownDuringRecordingStopsRecorderAndRestoresScreenIdleBehavior() async {
        let recorder = FakeIntakeAudioRecorder()
        let screenIdleController = FakeScreenIdleController()
        let viewModel = IntakeViewModel(screenIdleController: screenIdleController)
        viewModel.configure(
            profileStore: FakeProfileStore(),
            audioRecorder: recorder
        )

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        viewModel.tearDown()

        let fakeIdle = screenIdleController as? FakeScreenIdleController
        #expect(recorder.didStopRecording)
        #expect(!viewModel.isRecordingVoiceAnswer)
        #expect(!viewModel.isTranscribing)
        #expect(fakeIdle?.isIdleTimerDisabled == false)
        #expect(fakeIdle?.calls == [true, false])
    }

    @Test func skipCurrentPromptCancelsInFlightTranscription() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        let stopTask = viewModel.stopVoiceAnswer()
        #expect(viewModel.isTranscribing)

        viewModel.skipCurrentPrompt()
        client.finish(text: "should be discarded")
        await stopTask?.value

        #expect(!viewModel.isTranscribing)
        #expect(viewModel.response(for: .desiredSupport).voiceTranscript == "")
    }

    @Test func startingNewRecordingCancelsPreviousTranscription() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        let firstStop = viewModel.stopVoiceAnswer()
        #expect(viewModel.isTranscribing)

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        client.finish(text: "should not land")
        await firstStop?.value

        #expect(!viewModel.isTranscribing)
        #expect(viewModel.response(for: .desiredSupport).voiceTranscript == "")
    }

    @Test func transcriptionFailureSurfacesInlineErrorAndKeepsState() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )

        let desiredSupportPrompt = IntakeCopy.primaryPrompts[0]
        viewModel.toggleChip("calming-down", for: desiredSupportPrompt)
        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        let stopTask = viewModel.stopVoiceAnswer()

        client.fail(with: SampleTranscriptionError.boom)
        await stopTask?.value

        #expect(!viewModel.isTranscribing)
        #expect(viewModel.transcriptionError != nil)
        #expect(viewModel.response(for: .desiredSupport).selectedChipIDs.contains("calming-down"))
    }

    @Test func nextPrimaryIsBlockedWhileTranscribing() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )
        viewModel.begin()
        #expect(viewModel.step == .primary(0))

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        _ = viewModel.stopVoiceAnswer()
        #expect(viewModel.isTranscribing)

        viewModel.nextPrimary()

        #expect(viewModel.step == .primary(0))
    }

    @Test func nextOptionalIsBlockedWhileTranscribing() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )
        viewModel.begin()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.acceptOptionalTuning()
        #expect(viewModel.step == .optional(0))

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        _ = viewModel.stopVoiceAnswer()
        #expect(viewModel.isTranscribing)

        _ = viewModel.nextOptional()

        #expect(viewModel.step == .optional(0))
    }

    @Test func nextPrimaryIsBlockedWhileRecording() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )
        viewModel.begin()
        #expect(viewModel.step == .primary(0))

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        #expect(viewModel.isRecordingVoiceAnswer)

        viewModel.nextPrimary()

        #expect(viewModel.step == .primary(0))
    }

    @Test func nextOptionalIsBlockedWhileRecording() async {
        let recorder = FakeIntakeAudioRecorder()
        let client = ControllableFakeTranscriptionClient()
        let viewModel = IntakeViewModel()
        viewModel.configure(
            profileStore: FakeProfileStore(),
            transcriptionService: client,
            audioRecorder: recorder
        )
        viewModel.begin()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.nextPrimary()
        viewModel.acceptOptionalTuning()
        #expect(viewModel.step == .optional(0))

        await viewModel.startVoiceAnswer(for: .desiredSupport)?.value
        #expect(viewModel.isRecordingVoiceAnswer)

        _ = viewModel.nextOptional()

        #expect(viewModel.step == .optional(0))
    }
}

@MainActor
private final class FakeProfileStore: UserPracticeProfileStore {
    var savedProfile: UserPracticeProfile?
    var didMarkSkipped = false

    init(savedProfile: UserPracticeProfile? = nil) {
        self.savedProfile = savedProfile
    }

    func currentProfile() throws -> UserPracticeProfile? {
        savedProfile
    }

    func save(_ profile: UserPracticeProfile) throws {
        savedProfile = profile
    }

    func markSkipped() throws {
        didMarkSkipped = true
        savedProfile = .skipped()
    }
}

private struct FakeIntakeAnalyzer: IntakeAnalyzing {
    var result: UserPracticeProfile?
    var error: Error?

    func analyze(responses: [IntakeResponse], optionalTuningCompleted: Bool) async throws -> UserPracticeProfile {
        if let error {
            throw error
        }
        if let result {
            return UserPracticeProfile(
                completionState: result.completionState,
                optionalTuningCompleted: optionalTuningCompleted || result.optionalTuningCompleted,
                desiredSupportAreas: result.desiredSupportAreas,
                hardConstraints: result.hardConstraints,
                softPriors: result.softPriors
            )
        }
        return UserPracticeProfile(completionState: .completed, optionalTuningCompleted: optionalTuningCompleted)
    }
}

private final class FakeIntakeAudioRecorder: AudioRecording {
    var isRecording = false
    var recordingDuration: TimeInterval = 0
    var audioLevel: Float = 0
    var didStopRecording = false
    private let url: URL

    init(url: URL = URL(fileURLWithPath: "/tmp/fake-intake-recording.wav")) {
        self.url = url
    }

    func requestPermission() async -> Bool { true }

    func startRecording() throws -> URL {
        isRecording = true
        return url
    }

    func stopRecording() {
        didStopRecording = true
        isRecording = false
    }
}

private final class ControllableFakeTranscriptionClient: TranscriptionClient, @unchecked Sendable {
    var modelState: ModelState = .ready
    private var continuation: CheckedContinuation<(text: String, durationMs: Int), Error>?
    private var bufferedResult: Result<(text: String, durationMs: Int), Error>?

    func transcribe(audioURL: URL) async throws -> (text: String, durationMs: Int) {
        if let result = bufferedResult {
            bufferedResult = nil
            switch result {
            case .success(let value): return value
            case .failure(let error): throw error
            }
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func finish(text: String, durationMs: Int = 100) {
        if let c = continuation {
            continuation = nil
            c.resume(returning: (text, durationMs))
        } else {
            bufferedResult = .success((text, durationMs))
        }
    }

    func fail(with error: Error) {
        if let c = continuation {
            continuation = nil
            c.resume(throwing: error)
        } else {
            bufferedResult = .failure(error)
        }
    }
}

private enum SampleTranscriptionError: Error {
    case boom
}

private final class FakeScreenIdleController: ScreenIdleControlling {
    private(set) var calls: [Bool] = []
    private(set) var isIdleTimerDisabled = false

    func setIdleTimerDisabled(_ disabled: Bool) {
        calls.append(disabled)
        isIdleTimerDisabled = disabled
    }
}
