import SwiftUI

enum SuggestionViewContent {
    static let transcriptHeading = "You shared"
    static let rationaleHeading = "Why these might fit"
    static let practiceHeading = "Try one of these"
    static let relevanceHeading = "Why this might help"
    static let doneButtonTitle = "Done"
    static let tryButtonTitle = "Try This"

    static var mainUserFacingCopy: [String] {
        [
            transcriptHeading,
            rationaleHeading,
            practiceHeading,
            doneButtonTitle,
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
    let onSelect: (Practice) -> Void
    let onSkip: () -> Void

    @State private var expandedID: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(SuggestionViewContent.transcriptHeading)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(transcript)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(SuggestionViewContent.rationaleHeading)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(rationale)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text(SuggestionViewContent.practiceHeading)
                    .font(.headline)

                ForEach(practices) { practice in
                    practiceCard(practice)
                }

                Button(SuggestionViewContent.doneButtonTitle) {
                    onSkip()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }

    private func practiceCard(_ practice: Practice) -> some View {
        let isExpanded = expandedID == practice.id

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                expandedID = isExpanded ? nil : practice.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(practice.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("~\(practice.durationMinutes)m")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Text(practice.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())

                    if previouslyHelpfulIDs.contains(practice.id) {
                        Label("Helped before", systemImage: "hand.thumbsup.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                Text(practice.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(isExpanded ? nil : 2)

                if isExpanded, let relevance = relevanceByID[practice.id] {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(SuggestionViewContent.relevanceHeading)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(relevance)
                            .font(.caption)
                            .foregroundStyle(.indigo)
                    }
                    .padding(.top, 4)
                }

                if isExpanded {
                    Button {
                        onSelect(practice)
                    } label: {
                        Text(SuggestionViewContent.tryButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
