import SwiftUI
import UIKit

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
    static let display     = figtree(size: 30,   wght: 600)
    static let title       = figtree(size: 22,   wght: 600)
    static let heading     = figtree(size: 17,   wght: 600)
    static let body        = figtree(size: 14,   wght: 400)
    static let bodyMedium  = figtree(size: 14,   wght: 500)
    static let bodySemibold = figtree(size: 14,  wght: 600)
    static let caption     = figtree(size: 12,   wght: 500)
    static let eyebrow     = figtree(size: 11,   wght: 600)
    static let pill        = figtree(size: 10.5, wght: 500)
    static let pillSemibold = figtree(size: 10.5, wght: 600)
    static let nameBold    = figtree(size: 15,   wght: 600)
    static let summary     = figtree(size: 12.5, wght: 400)

    // Uses CoreText wght axis directly to avoid SwiftUI's broken weight resolution for variable fonts.
    static func figtree(size: CGFloat, wght: CGFloat) -> Font {
        let variationKey = UIFontDescriptor.AttributeName(rawValue: "CTFontVariationAttribute")
        let descriptor = UIFontDescriptor(fontAttributes: [
            .name: "Figtree",
            variationKey: [2003265652 as NSNumber: wght as NSNumber]  // 0x77676874 = 'wght'
        ])
        return Font(UIFont(descriptor: descriptor, size: size))
    }
}
