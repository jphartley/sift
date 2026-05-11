import SwiftUI

enum SuggestionViewContent {
    static let transcriptHeading = "YOU SHARED"
    static let rationaleHeading = "Why these might fit"
    static let practiceHeading = "Try one of these"
    static let relevanceHeading = "Why this might help"
    static let doneButtonTitle = "Done · maybe later"
    static let tryButtonTitle = "Try This"
    static let memoryHeading = "WHAT I REMEMBER"

    static var mainUserFacingCopy: [String] {
        [
            "You shared",
            rationaleHeading,
            practiceHeading,
            "Done",
            tryButtonTitle,
            relevanceHeading
        ]
    }
}

struct SuggestionView: View {
    let transcript: String
    let practices: [Practice]
    let rationale: String
    let wasEscalated: Bool
    let relevanceByID: [String: String]
    let previouslyHelpfulIDs: Set<String>
    var hasPriorSessions: Bool = false
    let onSelect: (Practice) -> Void
    let onSkip: () -> Void

    @State private var expandedID: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SiftSpace.sectGap) {
                transcriptSection
                if hasPriorSessions { memoryInsertCard }
                practiceSection
                Button(SuggestionViewContent.doneButtonTitle) { onSkip() }
                    .buttonStyle(GhostButtonStyle())
                Spacer().frame(height: 60)
            }
            .padding(.horizontal, SiftSpace.gutter)
            .padding(.top, SiftSpace.gutter)
        }
    }

    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(SuggestionViewContent.transcriptHeading)
                .font(SiftFont.eyebrow)
                .tracking(1.2)
                .foregroundStyle(SiftColor.quiet)
                .textCase(.uppercase)

            Text(transcript)
                .font(SiftFont.body.italic())
                .foregroundStyle(SiftColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !rationale.isEmpty {
                Text(SuggestionViewContent.rationaleHeading)
                    .font(SiftFont.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(SiftColor.quiet)
                    .textCase(.uppercase)
                    .padding(.top, 4)

                Text(rationale)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var memoryInsertCard: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(SiftColor.accent)
                .frame(width: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(SuggestionViewContent.memoryHeading)
                    .font(SiftFont.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(SiftColor.accentInk)
                    .textCase(.uppercase)

                Text(rationale)
                    .font(SiftFont.body)
                    .foregroundStyle(SiftColor.ink)
            }
            .padding(SiftSpace.cardPad)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SiftColor.surface)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: SiftRadius.tile,
                    topTrailingRadius: SiftRadius.tile
                )
            )
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: SiftRadius.tile,
                topTrailingRadius: SiftRadius.tile
            )
        )
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: SiftSpace.rowGap) {
            HStack {
                Text(SuggestionViewContent.practiceHeading)
                    .font(SiftFont.heading)
                    .foregroundStyle(SiftColor.ink)
                Spacer()
                Text("\(practices.count) suggestions")
                    .font(SiftFont.caption)
                    .foregroundStyle(SiftColor.quiet)
            }

            ForEach(practices) { practice in
                practiceCard(practice)
            }
        }
    }

    private func practiceCard(_ practice: Practice) -> some View {
        let isExpanded = expandedID == practice.id
        let isHelpful = previouslyHelpfulIDs.contains(practice.id)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandedID = isExpanded ? nil : practice.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(SiftColor.surfaceAlt)
                            .frame(width: 42, height: 42)
                        CategoryIcon(kind: practice.category, size: 24)
                            .foregroundStyle(SiftColor.accentInk)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(practice.name)
                                .font(SiftFont.nameBold)
                                .foregroundStyle(SiftColor.ink)
                            Spacer()
                            Text("~\(practice.durationMinutes)m")
                                .font(SiftFont.caption)
                                .foregroundStyle(SiftColor.quiet)
                        }

                        Text(practice.summary)
                            .font(SiftFont.summary)
                            .foregroundStyle(SiftColor.muted)
                            .lineSpacing(3)
                            .lineLimit(isExpanded ? nil : 2)

                        HStack(spacing: 6) {
                            PillTag(text: practice.category, tone: .soft)
                            if isHelpful {
                                PillTag(text: "✓ Helped before", tone: .helpful)
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                if isExpanded, let relevance = relevanceByID[practice.id], !relevance.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(SuggestionViewContent.relevanceHeading)
                            .font(SiftFont.eyebrow)
                            .tracking(1.2)
                            .foregroundStyle(SiftColor.quiet)
                            .textCase(.uppercase)
                        Text(relevance)
                            .font(SiftFont.body)
                            .foregroundStyle(SiftColor.muted)
                            .lineSpacing(3)
                    }
                }

                if isExpanded {
                    Button(SuggestionViewContent.tryButtonTitle) {
                        onSelect(practice)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 4)
                }
            }
            .padding(SiftSpace.cardPad)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SiftColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: SiftRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: SiftRadius.card)
                    .strokeBorder(SiftColor.line, lineWidth: 1)
            )
            .cardShadow()
        }
        .buttonStyle(.plain)
    }
}
