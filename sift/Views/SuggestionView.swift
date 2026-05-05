import SwiftUI

struct SuggestionView: View {
    let transcript: String
    let practices: [Practice]
    let rationale: String
    let wasEscalated: Bool
    let relevanceByID: [String: String]
    let previouslyHelpfulIDs: Set<String>
    let onSelect: (Practice) -> Void
    let onSkip: () -> Void

    @State private var showEscalatedToast = false

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

            VStack(alignment: .leading, spacing: 6) {
                Text("Analysis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(rationale)
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
        .onAppear {
            if wasEscalated {
                showEscalatedToast = true
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    showEscalatedToast = false
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showEscalatedToast {
                Text("Escalated to Pro model")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
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

                if let relevance = relevanceByID[practice.id] {
                    Text(relevance)
                        .font(.caption)
                        .foregroundStyle(.indigo)
                        .lineLimit(3)
                        .padding(.top, 4)
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
