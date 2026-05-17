import Foundation

enum IntakeStep: Equatable {
    case introduction
    case primary(Int)
    case optionalChoice
    case optional(Int)
    case analyzing
    case error(String)
    case complete
}

@Observable
final class IntakeViewModel {
    var step: IntakeStep = .introduction
    var responses: [IntakePromptID: IntakeResponse] = [:]
    var isRecordingVoiceAnswer = false
    var voiceCapturePromptID: IntakePromptID?
    var didFinish = false
    var isTranscribing = false
    var transcriptionError: String?
    var sentimentSheetPracticeID: String?

    private var profileStore: UserPracticeProfileStore?
    private var analyzer: IntakeAnalyzing
    private var audioRecorder: AudioRecording?
    private var transcriptionService: TranscriptionClient?
    private var currentRecordingURL: URL?
    private var optionalTuningCompleted = false
    private var transcriptionTask: Task<Void, Never>?

    init(analyzer: IntakeAnalyzing = LocalIntakeAnalyzer()) {
        self.analyzer = analyzer
    }

    func configure(
        profileStore: UserPracticeProfileStore,
        transcriptionService: TranscriptionClient? = nil,
        audioRecorder: AudioRecording? = nil,
        analyzer: IntakeAnalyzing? = nil
    ) {
        self.profileStore = profileStore
        self.transcriptionService = transcriptionService
        self.audioRecorder = audioRecorder
        if let analyzer {
            self.analyzer = analyzer
        }
    }

    func begin() {
        step = .primary(0)
    }

    func skipIntake() {
        do {
            try profileStore?.markSkipped()
            didFinish = true
            step = .complete
        } catch {
            step = .error("Sift could not save your choice. You can try again or begin check-in without this.")
        }
    }

    func continueWithoutAnalysis() {
        do {
            try profileStore?.markSkipped()
        } catch {
            step = .complete
            didFinish = true
            return
        }
        didFinish = true
        step = .complete
    }

    func toggleChip(_ chipID: String, for prompt: IntakePrompt) {
        var response = response(for: prompt.id)
        if prompt.id == .boundaries && chipID == "no-preference" {
            response.selectedChipIDs = response.selectedChipIDs.contains(chipID) ? [] : [chipID]
        } else {
            if response.selectedChipIDs.contains(chipID) {
                response.selectedChipIDs.remove(chipID)
                response.practiceSignals.removeValue(forKey: chipID)
            } else {
                response.selectedChipIDs.insert(chipID)
            }
            if prompt.id == .boundaries {
                response.selectedChipIDs.remove("no-preference")
            }
        }
        responses[prompt.id] = response
    }

    func selectPracticeFamily(_ familyID: String) {
        var response = response(for: .priorPractice)
        response.selectedChipIDs.insert(familyID)
        responses[.priorPractice] = response
        sentimentSheetPracticeID = familyID
    }

    func presentSentimentSheet(for familyID: String) {
        sentimentSheetPracticeID = familyID
    }

    func dismissSentimentSheet() {
        sentimentSheetPracticeID = nil
    }

    func setPracticeSignal(_ signal: PracticeExperienceSignal, for familyID: String) {
        var response = response(for: .priorPractice)
        response.selectedChipIDs.insert(familyID)
        response.practiceSignals[familyID] = signal
        responses[.priorPractice] = response
        sentimentSheetPracticeID = nil
    }

    func clearPracticeSignal(for familyID: String) {
        var response = response(for: .priorPractice)
        response.practiceSignals.removeValue(forKey: familyID)
        responses[.priorPractice] = response
    }

    func removePracticeFamily(_ familyID: String) {
        var response = response(for: .priorPractice)
        response.selectedChipIDs.remove(familyID)
        response.practiceSignals.removeValue(forKey: familyID)
        responses[.priorPractice] = response
        sentimentSheetPracticeID = nil
    }

    func setVoiceTranscript(_ transcript: String, for promptID: IntakePromptID) {
        var response = response(for: promptID)
        response.voiceTranscript = transcript
        responses[promptID] = response
    }

    func nextPrimary() {
        guard !isTranscribing, !isRecordingVoiceAnswer else { return }
        guard case .primary(let index) = step else { return }
        let next = index + 1
        if next < IntakeCopy.primaryPrompts.count {
            step = .primary(next)
        } else {
            step = .optionalChoice
        }
        transcriptionError = nil
    }

    func acceptOptionalTuning() {
        optionalTuningCompleted = true
        step = .optional(0)
        transcriptionError = nil
    }

    func declineOptionalTuning() -> Task<Void, Never> {
        optionalTuningCompleted = false
        return analyzeAndSave()
    }

    func nextOptional() -> Task<Void, Never>? {
        guard !isTranscribing, !isRecordingVoiceAnswer else { return nil }
        guard case .optional(let index) = step else { return nil }
        let next = index + 1
        if next < IntakeCopy.optionalPrompts.count {
            step = .optional(next)
            transcriptionError = nil
            return nil
        }
        return analyzeAndSave()
    }

    func retryAnalysis() -> Task<Void, Never> {
        analyzeAndSave()
    }

    func skipCurrentPrompt() {
        cancelTranscription()
    }

    func startVoiceAnswer(for promptID: IntakePromptID) -> Task<Void, Never>? {
        guard let audioRecorder else { return nil }
        cancelTranscription()
        transcriptionError = nil
        let task = Task { @MainActor in
            let hasPermission = await audioRecorder.requestPermission()
            guard hasPermission else {
                step = .error("Microphone permission is needed to add a voice answer.")
                return
            }
            do {
                currentRecordingURL = try audioRecorder.startRecording()
                voiceCapturePromptID = promptID
                isRecordingVoiceAnswer = true
            } catch {
                step = .error("Sift could not start recording that answer.")
            }
        }
        return task
    }

    func stopVoiceAnswer() -> Task<Void, Never>? {
        guard let transcriptionService,
              let recordingURL = currentRecordingURL,
              let promptID = voiceCapturePromptID else {
            audioRecorder?.stopRecording()
            isRecordingVoiceAnswer = false
            return nil
        }
        audioRecorder?.stopRecording()
        isRecordingVoiceAnswer = false
        isTranscribing = true
        transcriptionError = nil
        let task = Task { @MainActor in
            do {
                let result = try await transcriptionService.transcribe(audioURL: recordingURL)
                if Task.isCancelled {
                    try? FileManager.default.removeItem(at: recordingURL)
                    return
                }
                setVoiceTranscript(result.text.trimmingCharacters(in: .whitespacesAndNewlines), for: promptID)
                try? FileManager.default.removeItem(at: recordingURL)
                currentRecordingURL = nil
                voiceCapturePromptID = nil
                isTranscribing = false
                transcriptionTask = nil
            } catch {
                if Task.isCancelled {
                    try? FileManager.default.removeItem(at: recordingURL)
                    return
                }
                isTranscribing = false
                transcriptionTask = nil
                transcriptionError = "Sift couldn’t transcribe that. Try again or continue without it."
            }
        }
        transcriptionTask = task
        return task
    }

    func cancelTranscription() {
        transcriptionTask?.cancel()
        transcriptionTask = nil
        if isTranscribing {
            isTranscribing = false
            if let url = currentRecordingURL {
                try? FileManager.default.removeItem(at: url)
            }
            currentRecordingURL = nil
            voiceCapturePromptID = nil
        }
        transcriptionError = nil
    }

    func prompt(for step: IntakeStep) -> IntakePrompt? {
        switch step {
        case .primary(let index):
            guard IntakeCopy.primaryPrompts.indices.contains(index) else { return nil }
            return IntakeCopy.primaryPrompts[index]
        case .optional(let index):
            guard IntakeCopy.optionalPrompts.indices.contains(index) else { return nil }
            return IntakeCopy.optionalPrompts[index]
        default:
            return nil
        }
    }

    func response(for promptID: IntakePromptID) -> IntakeResponse {
        responses[promptID] ?? IntakeResponse(promptID: promptID)
    }

    private func analyzeAndSave() -> Task<Void, Never> {
        step = .analyzing
        let collectedResponses = Array(responses.values)
        let optionalCompleted = optionalTuningCompleted
        return Task { @MainActor in
            do {
                let profile = try await analyzer.analyze(
                    responses: collectedResponses,
                    optionalTuningCompleted: optionalCompleted
                )
                try profileStore?.save(profile)
                didFinish = true
                step = .complete
            } catch {
                step = .error("Sift could not save that context yet.")
            }
        }
    }
}
