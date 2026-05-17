import SwiftData
import SwiftUI

struct IntakeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TranscriptionService.self) private var transcriptionService
    @Environment(AudioRecorderService.self) private var audioRecorderService
    @State private var viewModel = IntakeViewModel()

    var body: some View {
        Group {
            switch viewModel.step {
            case .introduction:
                introductionView
            case .primary, .optional:
                if let prompt = viewModel.prompt(for: viewModel.step) {
                    promptView(prompt)
                }
            case .optionalChoice:
                optionalChoiceView
            case .analyzing:
                analyzingView
            case .error(let message):
                errorView(message)
            case .complete:
                EmptyView()
            }
        }
        .task {
            viewModel.configure(
                profileStore: SwiftDataUserPracticeProfileStore(modelContext: modelContext),
                transcriptionService: transcriptionService,
                audioRecorder: audioRecorderService
            )
        }
    }

    private var introductionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 44)
                Text("Make Sift fit you")
                    .font(SiftFont.display)
                    .foregroundStyle(SiftColor.ink)
                VStack(alignment: .leading, spacing: 14) {
                    Text(IntakeCopy.introduction)
                    Text(IntakeCopy.voiceIntroduction)
                }
                .font(SiftFont.body)
                .foregroundStyle(SiftColor.muted)
                .lineSpacing(4)
                VStack(spacing: 12) {
                    Button("Start") { viewModel.begin() }
                        .buttonStyle(PrimaryButtonStyle())
                    Button(IntakeCopy.skipIntakeAction) { viewModel.skipIntake() }
                        .buttonStyle(GhostButtonStyle())
                }
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.bottom, 120)
        }
    }

    private func promptView(_ prompt: IntakePrompt) -> some View {
        let response = viewModel.response(for: prompt.id)
        return ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 36)
                Text(prompt.title)
                    .font(SiftFont.title)
                    .foregroundStyle(SiftColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], alignment: .leading, spacing: 10) {
                    ForEach(prompt.chips) { chip in
                        if prompt.id == .priorPractice {
                            priorPracticeChipButton(chip, response: response)
                        } else {
                            standardChipButton(chip, prompt: prompt, response: response)
                        }
                    }
                }

                voiceAnswerView(prompt: prompt, response: response)

                HStack(spacing: 12) {
                    Button(IntakeCopy.skipAction) {
                        viewModel.skipCurrentPrompt()
                        advance(prompt: prompt)
                    }
                    .buttonStyle(GhostButtonStyle())
                    Button(IntakeCopy.nextAction) { advance(prompt: prompt) }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(viewModel.isTranscribing)
                }
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.bottom, 120)
        }
        .sheet(isPresented: Binding(
            get: { viewModel.sentimentSheetPracticeID != nil },
            set: { presented in
                if !presented { viewModel.dismissSentimentSheet() }
            }
        )) {
            if let familyID = viewModel.sentimentSheetPracticeID,
               let chip = IntakeCopy.primaryPrompts[1].chips.first(where: { $0.id == familyID }) {
                sentimentSheet(familyID: familyID, chipLabel: chip.label)
                    .presentationDetents([.medium])
            }
        }
    }

    private func standardChipButton(_ chip: IntakeChip, prompt: IntakePrompt, response: IntakeResponse) -> some View {
        let isSelected = response.selectedChipIDs.contains(chip.id)
        return Button {
            viewModel.toggleChip(chip.id, for: prompt)
        } label: {
            Text(chip.label)
                .font(SiftFont.caption)
                .foregroundStyle(isSelected ? SiftColor.accentInk : SiftColor.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, minHeight: 42)
                .padding(.horizontal, 10)
                .background(isSelected ? SiftColor.accentSoft : SiftColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func priorPracticeChipButton(_ chip: IntakeChip, response: IntakeResponse) -> some View {
        let isSelected = response.selectedChipIDs.contains(chip.id)
        let signal = response.practiceSignals[chip.id]
        let isLittleOrNo = chip.id == "little-or-no-prior-practice"
        let style = priorPracticeChipStyle(isSelected: isSelected, signal: signal, isLittleOrNo: isLittleOrNo)
        return Button {
            if isLittleOrNo {
                viewModel.toggleChip(chip.id, for: IntakeCopy.primaryPrompts[1])
                return
            }
            if isSelected {
                viewModel.presentSentimentSheet(for: chip.id)
            } else {
                viewModel.selectPracticeFamily(chip.id)
            }
        } label: {
            HStack(spacing: 6) {
                if let signalIcon = signal?.iconName {
                    Image(systemName: signalIcon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(style.foreground)
                }
                Text(chip.label)
                    .font(SiftFont.caption)
                    .foregroundStyle(style.foreground)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .padding(.horizontal, 10)
            .background(style.background)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style.borderColor, style: style.borderStyle)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private struct ChipStyle {
        let background: Color
        let foreground: Color
        let borderColor: Color
        let borderStyle: StrokeStyle
    }

    private func priorPracticeChipStyle(isSelected: Bool, signal: PracticeExperienceSignal?, isLittleOrNo: Bool) -> ChipStyle {
        let solidBorder = StrokeStyle(lineWidth: 0)
        let dashedBorder = StrokeStyle(lineWidth: 1.5, dash: [4, 3])
        if !isSelected {
            return ChipStyle(
                background: SiftColor.surface,
                foreground: SiftColor.muted,
                borderColor: .clear,
                borderStyle: solidBorder
            )
        }
        if isLittleOrNo {
            return ChipStyle(
                background: SiftColor.accentSoft,
                foreground: SiftColor.accentInk,
                borderColor: .clear,
                borderStyle: solidBorder
            )
        }
        guard let signal else {
            return ChipStyle(
                background: SiftColor.accentSoft.opacity(0.35),
                foreground: SiftColor.accentInk,
                borderColor: SiftColor.accent.opacity(0.55),
                borderStyle: dashedBorder
            )
        }
        switch signal {
        case .workedForMe:
            return ChipStyle(
                background: SiftColor.accentSoft,
                foreground: SiftColor.accentInk,
                borderColor: .clear,
                borderStyle: solidBorder
            )
        case .helpedSometimes:
            return ChipStyle(
                background: SiftColor.helpful.opacity(0.25),
                foreground: SiftColor.accentInk,
                borderColor: .clear,
                borderStyle: solidBorder
            )
        case .didNotReallyHelp:
            return ChipStyle(
                background: SiftColor.surfaceAlt,
                foreground: SiftColor.muted,
                borderColor: .clear,
                borderStyle: solidBorder
            )
        case .pleaseAvoid:
            return ChipStyle(
                background: SiftColor.danger.opacity(0.2),
                foreground: SiftColor.danger,
                borderColor: .clear,
                borderStyle: solidBorder
            )
        }
    }

    @ViewBuilder
    private func voiceAnswerView(prompt: IntakePrompt, response: IntakeResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let hint = prompt.voiceHint {
                Text(hint)
                    .font(SiftFont.caption)
                    .foregroundStyle(SiftColor.quiet)
            }

            if viewModel.isTranscribing {
                HStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Transcribing…")
                        .font(SiftFont.caption)
                        .foregroundStyle(SiftColor.muted)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(minHeight: 42)
                .background(SiftColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Button {
                    if viewModel.isRecordingVoiceAnswer {
                        _ = viewModel.stopVoiceAnswer()
                    } else {
                        _ = viewModel.startVoiceAnswer(for: prompt.id)
                    }
                } label: {
                    Label(
                        viewModel.isRecordingVoiceAnswer ? IntakeCopy.stopVoiceAction : IntakeCopy.voiceAction,
                        systemImage: viewModel.isRecordingVoiceAnswer ? "stop.fill" : "mic.fill"
                    )
                }
                .buttonStyle(GhostButtonStyle())
            }

            if let error = viewModel.transcriptionError {
                VStack(alignment: .leading, spacing: 8) {
                    Text(error)
                        .font(SiftFont.caption)
                        .foregroundStyle(SiftColor.danger)
                    HStack(spacing: 12) {
                        Button("Re-record") {
                            viewModel.transcriptionError = nil
                            _ = viewModel.startVoiceAnswer(for: prompt.id)
                        }
                        .font(SiftFont.caption)
                        .foregroundStyle(SiftColor.accent)
                        Button("Continue without it") {
                            viewModel.transcriptionError = nil
                        }
                        .font(SiftFont.caption)
                        .foregroundStyle(SiftColor.muted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(SiftColor.danger.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if !response.voiceTranscript.isEmpty {
                Text(response.voiceTranscript)
                    .font(SiftFont.caption)
                    .foregroundStyle(SiftColor.muted)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SiftColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func sentimentSheet(familyID: String, chipLabel: String) -> some View {
        let response = viewModel.response(for: .priorPractice)
        let currentSignal = response.practiceSignals[familyID]
        return VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
            Spacer().frame(height: 12)
            Text(chipLabel)
                .font(SiftFont.title)
                .foregroundStyle(SiftColor.ink)
            VStack(spacing: 10) {
                ForEach(PracticeExperienceSignal.allCases, id: \.self) { signal in
                    Button {
                        viewModel.setPracticeSignal(signal, for: familyID)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: signal.iconName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(currentSignal == signal ? SiftColor.accentInk : SiftColor.muted)
                                .frame(width: 22)
                            Text(signal.label)
                                .font(SiftFont.body)
                                .foregroundStyle(currentSignal == signal ? SiftColor.accentInk : SiftColor.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(currentSignal == signal ? SiftColor.accentSoft : SiftColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: SiftRadius.tile))
                    }
                    .buttonStyle(.plain)
                }
            }
            if currentSignal != nil {
                Button("Clear selection") {
                    viewModel.clearPracticeSignal(for: familyID)
                }
                .font(SiftFont.body)
                .foregroundStyle(SiftColor.muted)
                .frame(maxWidth: .infinity)
            }
            Button("Remove from selection") {
                viewModel.removePracticeFamily(familyID)
            }
            .font(SiftFont.body)
            .foregroundStyle(SiftColor.danger)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(.horizontal, SiftSpace.gutter)
        .padding(.top, 16)
    }

    private var optionalChoiceView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 44)
                Text(IntakeCopy.optionalTuning)
                    .font(SiftFont.title)
                    .foregroundStyle(SiftColor.ink)
                    .lineSpacing(4)
                VStack(spacing: 12) {
                    Button(IntakeCopy.answerMoreAction) { viewModel.acceptOptionalTuning() }
                        .buttonStyle(PrimaryButtonStyle())
                    Button(IntakeCopy.beginCheckInAction) { viewModel.declineOptionalTuning() }
                        .buttonStyle(GhostButtonStyle())
                }
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.bottom, 120)
        }
    }

    private var analyzingView: some View {
        VStack(spacing: 16) {
            BreathingDot()
                .frame(width: 80, height: 80)
            Text("Saving your preferences...")
                .font(SiftFont.body)
                .foregroundStyle(SiftColor.muted)
        }
    }

    private func errorView(_ message: String) -> some View {
        ScrollView {
            VStack(spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 60)
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 30))
                    .foregroundStyle(SiftColor.danger)
                Text(message)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.muted)
                    .multilineTextAlignment(.center)
                Button(IntakeCopy.retryAction) { viewModel.retryAnalysis() }
                    .buttonStyle(PrimaryButtonStyle())
                Button(IntakeCopy.continueWithoutAnalysisAction) { viewModel.continueWithoutAnalysis() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, SiftSpace.gutter)
        }
    }

    private func advance(prompt: IntakePrompt) {
        if IntakeCopy.primaryPrompts.contains(prompt) {
            viewModel.nextPrimary()
        } else {
            _ = viewModel.nextOptional()
        }
    }
}

private extension PracticeExperienceSignal {
    var iconName: String {
        switch self {
        case .workedForMe: return "checkmark.circle.fill"
        case .helpedSometimes: return "circle.lefthalf.filled"
        case .didNotReallyHelp: return "minus.circle"
        case .pleaseAvoid: return "nosign"
        }
    }

    var label: String {
        switch self {
        case .workedForMe: return "Worked for me"
        case .helpedSometimes: return "Helped sometimes"
        case .didNotReallyHelp: return "Didn’t really help"
        case .pleaseAvoid: return "Please avoid"
        }
    }
}
