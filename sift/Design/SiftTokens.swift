import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }
}

enum SiftColor {
    static let bg         = Color(hex: 0xDDE0EB)
    static let surface    = Color(hex: 0xECEDF3)
    static let surfaceAlt = Color(hex: 0xC8CCDD)
    static let ink        = Color(hex: 0x0E1430)
    static let muted      = Color(hex: 0x4A527A)
    static let quiet      = Color(hex: 0x8A90B0)
    static let line       = Color(hex: 0x0E1430, opacity: 0.10)
    static let accent     = Color(hex: 0x3A4AB0)
    static let accentSoft = Color(hex: 0xBCC4EC)
    static let accentInk  = Color(hex: 0x1A2270)
    static let helpful    = Color(hex: 0x5A7A9A)
    static let danger     = Color(hex: 0xA85674)
    static let tabIcon    = Color(hex: 0x7A82A4)
}

enum SiftRadius {
    static let card:   CGFloat = 18
    static let pill:   CGFloat = 999
    static let button: CGFloat = 18
    static let tile:   CGFloat = 14
}

enum SiftSpace {
    static let gutter:  CGFloat = 22
    static let cardPad: CGFloat = 16
    static let rowGap:  CGFloat = 10
    static let sectGap: CGFloat = 28
}

enum SiftFont {
    static let display  = Font.custom("Figtree", size: 30).weight(.semibold)
    static let title    = Font.custom("Figtree", size: 22).weight(.semibold)
    static let heading  = Font.custom("Figtree", size: 17).weight(.semibold)
    static let body     = Font.custom("Figtree", size: 14).weight(.regular)
    static let caption  = Font.custom("Figtree", size: 12).weight(.medium)
    static let eyebrow  = Font.custom("Figtree", size: 11).weight(.semibold)
    static let pill     = Font.custom("Figtree", size: 10.5).weight(.medium)
    static let nameBold = Font.custom("Figtree", size: 15).weight(.semibold)
    static let summary  = Font.custom("Figtree", size: 12.5).weight(.regular)
}
