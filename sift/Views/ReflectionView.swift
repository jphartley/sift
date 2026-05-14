import SwiftUI

struct ReflectionView: View {
    let practiceName: String
    let onSave: (Bool?, String?) -> Void

    @State private var viewModel = ReflectionViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AFTER")
                        .font(SiftFont.eyebrow)
                        .tracking(1.2)
                        .foregroundStyle(SiftColor.quiet)
                        .textCase(.uppercase)

                    Text("How did that land?")
                        .font(SiftFont.title)
                        .foregroundStyle(SiftColor.ink)
                }

                radioCard

                VStack(alignment: .leading, spacing: 6) {
                    TextField(
                        "(optional) anything else you want to mark…",
                        text: $viewModel.notes,
                        axis: .vertical
                    )
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.ink)
                    .tint(SiftColor.accent)
                    .lineLimit(3...6)
                    .padding(SiftSpace.cardPad)
                    .background(SiftColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: SiftRadius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: SiftRadius.card)
                            .strokeBorder(SiftColor.line, lineWidth: 1)
                    )
                }

                Spacer().frame(height: 80)
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.top, SiftSpace.gutter)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button("Save reflection") {
                    onSave(viewModel.wasHelpfulForSave, viewModel.notesForSave)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Skip for now") {
                    onSave(nil, nil)
                }
                .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
    }

    private var radioCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(ReflectionViewModel.HelpfulnessOption.allCases.enumerated()), id: \.offset) { idx, option in
                VStack(spacing: 0) {
                    if idx > 0 {
                        Divider()
                            .background(SiftColor.line)
                    }
                    radioRow(option)
                }
            }
        }
        .background(SiftColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: SiftRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: SiftRadius.card)
                .strokeBorder(SiftColor.line, lineWidth: 1)
        )
        .cardShadow()
    }

    private func radioRow(_ option: ReflectionViewModel.HelpfulnessOption) -> some View {
        let isSelected = viewModel.selectedHelpfulness == option
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectedHelpfulness = option
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? SiftColor.accent : SiftColor.line, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(SiftColor.accent)
                            .frame(width: 10, height: 10)
                    }
                }

                Text(option.label)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.ink)

                Spacer()
            }
            .padding(.horizontal, SiftSpace.cardPad)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
