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
            VStack(alignment: .leading, spacing: 24) {
                Button("Back") {
                    onBack()
                }
                .font(.subheadline)

                VStack(alignment: .leading, spacing: 8) {
                    Text(practice.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        Text(practice.category)
                        Text("~\(practice.durationMinutes)m")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                if !relevance.isEmpty {
                    section("Why this was suggested") {
                        Text(relevance)
                            .font(.body)
                            .foregroundStyle(.indigo)
                    }
                }

                section("What it is") {
                    Text(practice.summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                section("One way to practice") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(practice.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1).")
                                    .font(.body.monospacedDigit())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 28, alignment: .trailing)

                                Text(step)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }

                section("Why it helps") {
                    Text(practice.whyItHelps)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if showsGentleNote {
                    gentleNote
                }
            }
            .padding()
            .padding(.bottom, 96)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                onComplete()
            } label: {
                Text("I did this")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.regularMaterial)
        }
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var gentleNoteHighIntensityText: String {
        "This is a higher-intensity practice. Go slowly, adapt, or stop if it does not feel right today."
    }

    var gentleNoteAvoidWhenText: String {
        "Avoid this when: \(practice.avoidWhen.joined(separator: ", ")). You can adapt or stop the practice."
    }

    private var gentleNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("A gentle note", systemImage: "info.circle")
                .font(.headline)

            if practice.intensity == "high" {
                Text(gentleNoteHighIntensityText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !practice.avoidWhen.isEmpty {
                Text(gentleNoteAvoidWhenText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
