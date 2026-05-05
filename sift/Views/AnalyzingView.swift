import SwiftUI

struct AnalyzingView: View {
    let transcript: String

    @State private var showTranscript = false

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Analyzing...")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if showTranscript, !transcript.isEmpty {
                Text(transcript)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.4)) {
                showTranscript = true
            }
        }
    }
}
