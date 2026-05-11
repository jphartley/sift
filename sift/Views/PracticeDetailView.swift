import SwiftUI

struct PracticeDetailView: View {
    let practice: Practice
    let relevance: String
    let onBack: () -> Void
    let onComplete: () -> Void

    var showsGentleNote: Bool {
        practice.intensity == "high" || !practice.avoidWhen.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Back")
                            .font(SiftFont.body)
                    }
                    .foregroundStyle(SiftColor.muted)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(practice.category.uppercased()) · ~\(practice.durationMinutes) MIN")
                        .font(SiftFont.eyebrow)
                        .tracking(1.2)
                        .foregroundStyle(SiftColor.quiet)

                    Text(practice.name)
                        .font(SiftFont.display)
                        .foregroundStyle(SiftColor.ink)

                    Text(practice.summary)
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .lineSpacing(4)
                }

                if !relevance.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("WHY THIS MIGHT HELP")
                            .font(SiftFont.eyebrow)
                            .tracking(1.2)
                            .foregroundStyle(SiftColor.quiet)
                        Text(relevance)
                            .font(SiftFont.body)
                            .foregroundStyle(SiftColor.muted)
                            .lineSpacing(4)
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("ONE WAY TO PRACTICE")
                        .font(SiftFont.eyebrow)
                        .tracking(1.2)
                        .foregroundStyle(SiftColor.quiet)
                        .padding(.bottom, 12)

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(practice.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(SiftColor.surfaceAlt)
                                        .frame(width: 24, height: 24)
                                    Text("\(index + 1)")
                                        .font(SiftFont.heading)
                                        .foregroundStyle(SiftColor.accentInk)
                                }

                                Text(step)
                                    .font(SiftFont.body)
                                    .foregroundStyle(SiftColor.ink)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            if index < practice.steps.count - 1 {
                                Spacer().frame(height: 12)
                            }
                        }
                    }
                    .padding(SiftSpace.cardPad)
                    .background(SiftColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: SiftRadius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: SiftRadius.card)
                            .strokeBorder(SiftColor.line, lineWidth: 1)
                    )
                    .cardShadow()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("WHY IT HELPS")
                        .font(SiftFont.eyebrow)
                        .tracking(1.2)
                        .foregroundStyle(SiftColor.quiet)
                    Text(practice.whyItHelps)
                        .font(SiftFont.body.italic())
                        .foregroundStyle(SiftColor.muted)
                        .lineSpacing(4)
                }

                if showsGentleNote {
                    gentleNote
                }

                Spacer().frame(height: 96)
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.top, SiftSpace.gutter)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button {
                    onComplete()
                } label: {
                    Text("I did this")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
    }

    var gentleNoteHighIntensityText: String {
        "This is a higher-intensity practice. Go slowly, adapt, or stop if it does not feel right today."
    }

    var gentleNoteAvoidWhenText: String {
        "Avoid this when: \(practice.avoidWhen.joined(separator: ", ")). You can adapt or stop the practice."
    }

    private var gentleNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("A GENTLE NOTE")
                .font(SiftFont.eyebrow)
                .tracking(1.2)
                .foregroundStyle(SiftColor.quiet)

            if practice.intensity == "high" {
                Text(gentleNoteHighIntensityText)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.muted)
                    .lineSpacing(4)
            }
            if !practice.avoidWhen.isEmpty {
                Text(gentleNoteAvoidWhenText)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.muted)
                    .lineSpacing(4)
            }
        }
        .padding(SiftSpace.cardPad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SiftColor.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: SiftRadius.card))
    }
}
