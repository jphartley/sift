import SwiftUI

enum PillTone {
    case `default`, soft, helpful
}

struct PillTag: View {
    let text: String
    var tone: PillTone = .default

    var bg: Color {
        switch tone {
        case .default: return .clear
        case .soft:    return SiftColor.surfaceAlt
        case .helpful: return .clear
        }
    }

    var fg: Color {
        switch tone {
        case .default: return SiftColor.muted
        case .soft:    return SiftColor.muted
        case .helpful: return SiftColor.helpful
        }
    }

    var border: Color {
        switch tone {
        case .default: return SiftColor.line
        case .soft:    return .clear
        case .helpful: return SiftColor.helpful
        }
    }

    var body: some View {
        Text(text)
            .font(SiftFont.pill)
            .tracking(0.2)
            .foregroundStyle(fg)
            .padding(.vertical, 3)
            .padding(.horizontal, 9)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: SiftRadius.pill))
            .overlay(
                RoundedRectangle(cornerRadius: SiftRadius.pill)
                    .strokeBorder(border, lineWidth: 0.5)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var soft: Bool = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SiftFont.nameBold)
            .foregroundStyle(soft ? SiftColor.accentInk : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .background(soft ? SiftColor.accentSoft : SiftColor.accent)
            .clipShape(RoundedRectangle(cornerRadius: SiftRadius.button))
            .overlay(
                RoundedRectangle(cornerRadius: SiftRadius.button)
                    .strokeBorder(Color.white.opacity(soft ? 0 : 0.2), lineWidth: 1)
            )
            .shadow(
                color: soft ? .clear : SiftColor.accent.opacity(0.18),
                radius: 16, x: 0, y: 6
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SiftFont.bodyMedium)
            .foregroundStyle(SiftColor.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 22)
            .background(.clear)
            .clipShape(RoundedRectangle(cornerRadius: SiftRadius.button))
            .overlay(
                RoundedRectangle(cornerRadius: SiftRadius.button)
                    .strokeBorder(SiftColor.line, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct CardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(CardShadow())
    }
}

struct BreathingDot: View {
    @State private var phase: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .strokeBorder(SiftColor.accent, lineWidth: 1.2)
                    .frame(width: 24 + CGFloat(i) * 18, height: 24 + CGFloat(i) * 18)
                    .opacity(0.35 - Double(i) * 0.08)
                    .scaleEffect(1 + 0.06 * sin(phase + Double(i) * 0.9))
            }
            Circle()
                .fill(SiftColor.accent)
                .frame(width: 10, height: 10)
        }
        .onAppear {
            withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}
