import SwiftUI

struct CategoryIcon: View {
    let kind: String
    var size: CGFloat = 24

    private var resolved: String {
        switch kind {
        case "Reflection":  return "Journaling"
        case "Connection":  return "Social Connection"
        case "Rest":        return "Sleep & Wind-Down"
        default:            return kind
        }
    }

    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 28
            ctx.transform = CGAffineTransform(scaleX: s, y: s)
            draw(ctx: ctx)
        }
        .frame(width: size, height: size)
    }

    private func draw(ctx: GraphicsContext) {
        let sw: CGFloat = 1.4
        let s = ctx
        s.stroke(Path { _ in }, with: .foreground, lineWidth: sw)

        func stroke(_ p: Path, lw: CGFloat = sw) {
            let c = ctx
            c.stroke(p, with: .foreground,
                     style: StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round))
        }
        func fill(_ p: Path) {
            let c = ctx
            c.fill(p, with: .foreground)
        }

        switch resolved {

        case "Breathwork":
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 4.5, y: 4.5, width: 19, height: 19))
            })
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 8.5, y: 8.5, width: 11, height: 11))
            })
            fill(Path(ellipseIn: CGRect(x: 12.4, y: 12.4, width: 3.2, height: 3.2)))

        case "Meditation":
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 11.6, y: 5.1, width: 4.8, height: 4.8))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 6, y: 22))
                p.addCurve(to: CGPoint(x: 22, y: 22),
                           control1: CGPoint(x: 8, y: 17),
                           control2: CGPoint(x: 14, y: 15))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 22)); p.addLine(to: CGPoint(x: 23, y: 22))
            })

        case "Grounding":
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 5)); p.addLine(to: CGPoint(x: 14, y: 14))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 9))
                p.addCurve(to: CGPoint(x: 9, y: 8),
                           control1: CGPoint(x: 12, y: 7.5), control2: CGPoint(x: 10.5, y: 7.5))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 9))
                p.addCurve(to: CGPoint(x: 19, y: 8),
                           control1: CGPoint(x: 16, y: 7.5), control2: CGPoint(x: 17.5, y: 7.5))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 3, y: 16)); p.addLine(to: CGPoint(x: 25, y: 16))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 7, y: 20))
                p.addCurve(to: CGPoint(x: 11, y: 20),
                           control1: CGPoint(x: 8.5, y: 19), control2: CGPoint(x: 9.5, y: 19))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 13, y: 20))
                p.addCurve(to: CGPoint(x: 17, y: 20),
                           control1: CGPoint(x: 14.5, y: 19), control2: CGPoint(x: 15.5, y: 19))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 19, y: 23))
                p.addCurve(to: CGPoint(x: 22, y: 23),
                           control1: CGPoint(x: 20, y: 22.3), control2: CGPoint(x: 21, y: 22.3))
            })

        case "Movement":
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 13, y: 3.5, width: 4, height: 4))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 15, y: 8))
                p.addLine(to: CGPoint(x: 13, y: 14))
                p.addLine(to: CGPoint(x: 17, y: 15))
                p.addLine(to: CGPoint(x: 18, y: 20))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 13, y: 14)); p.addLine(to: CGPoint(x: 9, y: 19))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 17, y: 9)); p.addLine(to: CGPoint(x: 21, y: 11))
            })

        case "Journaling":
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 7)); p.addLine(to: CGPoint(x: 5, y: 22))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 23, y: 7)); p.addLine(to: CGPoint(x: 23, y: 22))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 7))
                p.addCurve(to: CGPoint(x: 14, y: 7),
                           control1: CGPoint(x: 8, y: 5.5), control2: CGPoint(x: 11, y: 5.5))
                p.addCurve(to: CGPoint(x: 23, y: 7),
                           control1: CGPoint(x: 17, y: 5.5), control2: CGPoint(x: 20, y: 5.5))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 22))
                p.addCurve(to: CGPoint(x: 14, y: 22),
                           control1: CGPoint(x: 8, y: 20.5), control2: CGPoint(x: 11, y: 20.5))
                p.addCurve(to: CGPoint(x: 23, y: 22),
                           control1: CGPoint(x: 17, y: 20.5), control2: CGPoint(x: 20, y: 20.5))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 7)); p.addLine(to: CGPoint(x: 14, y: 22))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 17, y: 13)); p.addLine(to: CGPoint(x: 21, y: 10))
            }, lw: 1.6)

        case "Emotional Processing":
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 22))
                p.addCurve(to: CGPoint(x: 5, y: 11),
                           control1: CGPoint(x: 8, y: 18), control2: CGPoint(x: 5, y: 15))
                p.addArc(center: CGPoint(x: 9, y: 8.5), radius: 3.5,
                         startAngle: .degrees(210), endAngle: .degrees(0), clockwise: false)
                p.addArc(center: CGPoint(x: 19, y: 8.5), radius: 3.5,
                         startAngle: .degrees(180), endAngle: .degrees(330), clockwise: false)
                p.addCurve(to: CGPoint(x: 14, y: 22),
                           control1: CGPoint(x: 23, y: 15), control2: CGPoint(x: 20, y: 18))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 9, y: 12))
                p.addCurve(to: CGPoint(x: 14, y: 12),
                           control1: CGPoint(x: 10.5, y: 13), control2: CGPoint(x: 12.5, y: 13))
                p.addCurve(to: CGPoint(x: 19, y: 12),
                           control1: CGPoint(x: 15.5, y: 13), control2: CGPoint(x: 17.5, y: 13))
            })

        case "Social Connection":
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 6.8, y: 5.8, width: 4.4, height: 4.4))
            })
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 16.8, y: 5.8, width: 4.4, height: 4.4))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 4, y: 22))
                p.addCurve(to: CGPoint(x: 9, y: 16),
                           control1: CGPoint(x: 4, y: 18), control2: CGPoint(x: 6, y: 16))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 24, y: 22))
                p.addCurve(to: CGPoint(x: 19, y: 16),
                           control1: CGPoint(x: 24, y: 18), control2: CGPoint(x: 22, y: 16))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 11, y: 16))
                p.addCurve(to: CGPoint(x: 14, y: 16),
                           control1: CGPoint(x: 12, y: 16.5), control2: CGPoint(x: 13, y: 16.5))
                p.move(to: CGPoint(x: 14, y: 16))
                p.addCurve(to: CGPoint(x: 17, y: 16),
                           control1: CGPoint(x: 15, y: 16.5), control2: CGPoint(x: 16, y: 16.5))
            })

        case "Nature":
            stroke(Path { p in
                p.move(to: CGPoint(x: 22, y: 6))
                p.addCurve(to: CGPoint(x: 10.5, y: 22),
                           control1: CGPoint(x: 13, y: 6), control2: CGPoint(x: 7, y: 14))
                p.addCurve(to: CGPoint(x: 22, y: 6),
                           control1: CGPoint(x: 16, y: 22), control2: CGPoint(x: 22, y: 16))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 22, y: 6)); p.addLine(to: CGPoint(x: 9, y: 19))
            })

        case "Creative Expression":
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 22))
                p.addCurve(to: CGPoint(x: 16, y: 7),
                           control1: CGPoint(x: 8, y: 21), control2: CGPoint(x: 12, y: 13))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 22))
                p.addCurve(to: CGPoint(x: 10, y: 19.5),
                           control1: CGPoint(x: 7, y: 21.6), control2: CGPoint(x: 8.5, y: 21))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 19, y: 6)); p.addLine(to: CGPoint(x: 20.6, y: 4.4))
                p.move(to: CGPoint(x: 22, y: 9)); p.addLine(to: CGPoint(x: 24.2, y: 9))
                p.move(to: CGPoint(x: 21, y: 12)); p.addLine(to: CGPoint(x: 22.6, y: 13))
            }, lw: 1.2)

        case "Practical Care":
            stroke(Path { p in
                p.move(to: CGPoint(x: 6, y: 12))
                p.addLine(to: CGPoint(x: 19, y: 12))
                p.addLine(to: CGPoint(x: 19, y: 20))
                p.addArc(center: CGPoint(x: 16, y: 20), radius: 3,
                         startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                p.addLine(to: CGPoint(x: 9, y: 23))
                p.addArc(center: CGPoint(x: 9, y: 20), radius: 3,
                         startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                p.addLine(to: CGPoint(x: 6, y: 12))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 19, y: 14))
                p.addLine(to: CGPoint(x: 21, y: 14))
                p.addArc(center: CGPoint(x: 21, y: 16.5), radius: 2.5,
                         startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                p.addLine(to: CGPoint(x: 19, y: 19))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 10, y: 8))
                p.addCurve(to: CGPoint(x: 11, y: 5),
                           control1: CGPoint(x: 10, y: 7), control2: CGPoint(x: 11, y: 6.5))
                p.move(to: CGPoint(x: 14, y: 8))
                p.addCurve(to: CGPoint(x: 15, y: 5),
                           control1: CGPoint(x: 14, y: 7), control2: CGPoint(x: 15, y: 6.5))
            })

        case "Sleep & Wind-Down":
            stroke(Path { p in
                p.move(to: CGPoint(x: 21, y: 16))
                p.addArc(center: CGPoint(x: 12.5, y: 12.5), radius: 8.5,
                         startAngle: .degrees(-10), endAngle: .degrees(230), clockwise: false)
                p.addCurve(to: CGPoint(x: 21, y: 16),
                           control1: CGPoint(x: 14, y: 24), control2: CGPoint(x: 19, y: 22))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 19, y: 6)); p.addLine(to: CGPoint(x: 19.6, y: 6.6))
                p.move(to: CGPoint(x: 22, y: 8)); p.addLine(to: CGPoint(x: 22.8, y: 8))
                p.move(to: CGPoint(x: 20, y: 10)); p.addLine(to: CGPoint(x: 20.6, y: 9.6))
            }, lw: 1.1)

        case "Self-Compassion":
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 14))
                p.addCurve(to: CGPoint(x: 9, y: 8),
                           control1: CGPoint(x: 11, y: 12), control2: CGPoint(x: 9, y: 10.5))
                p.addArc(center: CGPoint(x: 11.6, y: 7.4), radius: 2.6,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                p.addArc(center: CGPoint(x: 16.4, y: 7.4), radius: 2.6,
                         startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                p.addCurve(to: CGPoint(x: 14, y: 14),
                           control1: CGPoint(x: 19, y: 10.5), control2: CGPoint(x: 17, y: 12))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 17))
                p.addCurve(to: CGPoint(x: 10, y: 17),
                           control1: CGPoint(x: 6.5, y: 16), control2: CGPoint(x: 8, y: 16))
                p.addLine(to: CGPoint(x: 14, y: 19))
                p.addCurve(to: CGPoint(x: 20, y: 17),
                           control1: CGPoint(x: 16, y: 19.8), control2: CGPoint(x: 18, y: 18.6))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 5, y: 17)); p.addLine(to: CGPoint(x: 5, y: 22))
            })

        case "Values & Intention":
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 4.5, y: 4.5, width: 19, height: 19))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 5.5))
                p.addLine(to: CGPoint(x: 17, y: 14))
                p.addLine(to: CGPoint(x: 14, y: 17))
                p.addLine(to: CGPoint(x: 11, y: 14))
                p.addLine(to: CGPoint(x: 14, y: 5.5))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 14))
                p.addLine(to: CGPoint(x: 11, y: 22.5))
                p.addLine(to: CGPoint(x: 14, y: 19.5))
                p.addLine(to: CGPoint(x: 17, y: 22.5))
                p.addLine(to: CGPoint(x: 14, y: 14))
            })

        case "Spiritual / Contemplative":
            stroke(Path { p in
                p.move(to: CGPoint(x: 14, y: 4))
                p.addCurve(to: CGPoint(x: 9.5, y: 12),
                           control1: CGPoint(x: 11, y: 7), control2: CGPoint(x: 9.5, y: 9.5))
                p.addArc(center: CGPoint(x: 14, y: 12), radius: 4.5,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                p.addCurve(to: CGPoint(x: 14, y: 4),
                           control1: CGPoint(x: 18.5, y: 9.5), control2: CGPoint(x: 17, y: 7))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 9, y: 19)); p.addLine(to: CGPoint(x: 19, y: 19))
            })
            stroke(Path { p in
                p.move(to: CGPoint(x: 11, y: 22)); p.addLine(to: CGPoint(x: 17, y: 22))
            })

        default:
            stroke(Path { p in
                p.addEllipse(in: CGRect(x: 4, y: 4, width: 20, height: 20))
            })
        }
    }
}
