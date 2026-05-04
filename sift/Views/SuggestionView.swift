import SwiftUI

struct SuggestionView: View {
    let transcript: String
    let practices: [Practice]
    let previouslyHelpfulIDs: Set<String>
    let onSelect: (Practice) -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("You shared")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(transcript)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text("Try one of these")
                .font(.headline)

            ForEach(practices) { practice in
                practiceCard(practice)
            }

            Button("Done") {
                onSkip()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }

    private func practiceCard(_ practice: Practice) -> some View {
        Button {
            onSelect(practice)
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

                Text(practice.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
