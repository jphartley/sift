import SwiftUI

struct AnalyzingView: View {
    let transcript: String

    @State private var showTranscript = false

    var body: some View {
        ScrollView {
            VStack(spacing: SiftSpace.sectGap) {
                Spacer().frame(height: 80)

                BreathingDot()
                    .frame(width: 80, height: 80)

                VStack(spacing: 10) {
                    Text("Reading what you shared")
                        .font(SiftFont.heading)
                        .foregroundStyle(SiftColor.ink)
                        .multilineTextAlignment(.center)

                    Text("A moment of quiet while I take it in.")
                        .font(SiftFont.body)
                        .foregroundStyle(SiftColor.muted)
                        .multilineTextAlignment(.center)
                }

                if showTranscript, !transcript.isEmpty {
                    Text(transcript)
                        .font(SiftFont.body.italic())
                        .foregroundStyle(SiftColor.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(SiftSpace.cardPad)
                        .background(SiftColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: SiftRadius.card))
                        .overlay(
                            RoundedRectangle(cornerRadius: SiftRadius.card)
                                .strokeBorder(SiftColor.line, lineWidth: 1)
                        )
                        .cardShadow()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, SiftSpace.gutter)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.4)) {
                showTranscript = true
            }
        }
    }
}
