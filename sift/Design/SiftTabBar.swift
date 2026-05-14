import SwiftUI

enum SiftTab {
    case today, history, privacy
}

struct SiftTabBar: View {
    @Binding var selected: SiftTab

    var body: some View {
        HStack(spacing: 0) {
            tabItem(.today,   label: "Today",   icon: todayIcon,   accessLabel: "Record")
            tabItem(.history, label: "History", icon: historyIcon, accessLabel: "History")
            tabItem(.privacy, label: "Privacy", icon: privacyIcon, accessLabel: "Privacy")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(SiftColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(SiftColor.line, lineWidth: 1)
        )
        .cardShadow()
        .padding(.horizontal, 12)
        .padding(.bottom, 26)
    }

    private func tabItem(_ tab: SiftTab, label: String, icon: some View, accessLabel: String) -> some View {
        let isActive = selected == tab
        return Button {
            selected = tab
        } label: {
            VStack(spacing: 3) {
                icon
                    .frame(width: 22, height: 22)
                Text(label)
                    .font(SiftFont.pill)
                    .fontWeight(isActive ? .semibold : .medium)
                    .tracking(0.1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(isActive ? SiftColor.surfaceAlt : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .foregroundStyle(isActive ? SiftColor.accent : SiftColor.tabIcon)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessLabel)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isActive)
    }

    private var todayIcon: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let outer: CGFloat = 8, inner: CGFloat = 3.2
            let stroke = ctx
            stroke.stroke(
                Path { p in p.addEllipse(in: CGRect(x: cx - outer, y: cy - outer,
                                                    width: outer * 2, height: outer * 2)) },
                with: .foreground,
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
            )
            stroke.stroke(
                Path { p in p.addEllipse(in: CGRect(x: cx - inner, y: cy - inner,
                                                    width: inner * 2, height: inner * 2)) },
                with: .foreground,
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
            )
        }
    }

    private var historyIcon: some View {
        Canvas { ctx, size in
            let left: CGFloat = 4, right: CGFloat = 18
            let stroke = ctx
            for y in [CGFloat(7), 11, 15] {
                stroke.stroke(
                    Path { p in
                        p.move(to: CGPoint(x: left, y: y))
                        p.addLine(to: CGPoint(x: y == 15 ? 13 : right, y: y))
                    },
                    with: .foreground,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
            }
        }
    }

    private var privacyIcon: some View {
        Canvas { ctx, size in
            let stroke = ctx
            stroke.stroke(
                Path { p in
                    p.move(to: CGPoint(x: 11, y: 3))
                    p.addLine(to: CGPoint(x: 4, y: 6))
                    p.addLine(to: CGPoint(x: 4, y: 11))
                    p.addCurve(to: CGPoint(x: 11, y: 19),
                               control1: CGPoint(x: 4, y: 15), control2: CGPoint(x: 7, y: 18))
                    p.addCurve(to: CGPoint(x: 18, y: 11),
                               control1: CGPoint(x: 15, y: 18), control2: CGPoint(x: 18, y: 15))
                    p.addLine(to: CGPoint(x: 18, y: 6))
                    p.addLine(to: CGPoint(x: 11, y: 3))
                },
                with: .foreground,
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
