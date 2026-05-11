import SwiftUI

struct WaveformRibbon: View {
    var height: CGFloat = 80

    private struct Layer {
        let phase: Double
        let amplitude: Double
        let opacity: Double
        let strokeWidth: CGFloat
        let period: Double
    }

    private let layers: [Layer] = [
        Layer(phase: 0,   amplitude: 22, opacity: 0.95, strokeWidth: 2.2, period: 5.0),
        Layer(phase: 1.6, amplitude: 16, opacity: 0.55, strokeWidth: 1.8, period: 5.7),
        Layer(phase: 3.1, amplitude: 11, opacity: 0.30, strokeWidth: 1.4, period: 6.4),
    ]

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for layer in layers {
                    let phaseOffset = (t / layer.period) * .pi * 2
                    let path = sinePath(
                        phase: layer.phase + phaseOffset,
                        amplitude: layer.amplitude,
                        size: size
                    )
                    var stroke = ctx
                    stroke.opacity = layer.opacity
                    stroke.stroke(
                        path,
                        with: .foreground,
                        style: StrokeStyle(
                            lineWidth: layer.strokeWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    private func sinePath(phase: Double, amplitude: Double, size: CGSize) -> Path {
        let N = 60
        var points: [CGPoint] = []
        for i in 0...N {
            let x = (Double(i) / Double(N)) * size.width
            let t = (Double(i) / Double(N)) * .pi * 2.4
            let taper = 1.0 - abs(Double(i) / Double(N) * 2.0 - 1.0) * 0.6
            let y = size.height / 2 + sin(t + phase) * amplitude * taper
            points.append(CGPoint(x: x, y: y))
        }
        var path = Path()
        if let first = points.first {
            path.move(to: first)
            for pt in points.dropFirst() {
                path.addLine(to: pt)
            }
        }
        return path
    }
}
