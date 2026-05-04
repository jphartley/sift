import SwiftUI

struct SessionDetailView: View {
    let session: Session

    var body: some View {
        List {
            Section("Transcript") {
                Text(session.transcript)
                    .font(.body)
            }

            Section("Details") {
                LabeledContent("Date", value: session.timestamp.formatted(date: .long, time: .shortened))
                LabeledContent("Duration", value: "\(Int(session.audioDuration))s")
                LabeledContent("Transcription", value: "\(session.transcriptionDurationMs)ms")
            }

            if !session.attempts.isEmpty {
                Section("Practices") {
                    ForEach(session.attempts) { attempt in
                        practiceAttemptRow(attempt)
                    }
                }
            }
        }
        .navigationTitle("Check-In")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func practiceAttemptRow(_ attempt: PracticeAttempt) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(attempt.practiceName)
                    .font(.body)

                if let notes = attempt.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if let wasHelpful = attempt.wasHelpful {
                Image(systemName: wasHelpful ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                    .foregroundStyle(wasHelpful ? .green : .orange)
            }
        }
        .padding(.vertical, 4)
    }
}
