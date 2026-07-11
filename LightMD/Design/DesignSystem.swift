import SwiftUI

struct DesignPalette {
    let appBackground: Color
    let documentSurface: Color
    let editorSurface: Color
    let primaryText: Color
    let secondaryText: Color
    let mutedText: Color
    let border: Color
    let subtleBorder: Color
    let codeBackground: Color
    let inlineCodeBackground: Color
    let quoteBackground: Color
    let toolbarControlBackground: Color
    let badgeBackground: Color
    let cardShadow: Color
    let annotationHighlight: Color
    let annotationUnderline: Color
    let annotationControlBackground: Color
}

enum DesignSystem {
    static let readerMaxWidth: CGFloat = 820
    static let editorMaxWidth: CGFloat = 980
    static let welcomeMaxWidth: CGFloat = 680
    static let documentCornerRadius: CGFloat = 16
    static let controlCornerRadius: CGFloat = 8
    static let readerHorizontalPadding: CGFloat = 56
    static let readerVerticalPadding: CGFloat = 48
    static let windowMinWidth: CGFloat = 820
    static let windowMinHeight: CGFloat = 560

    static func palette(for scheme: ColorScheme) -> DesignPalette {
        switch scheme {
        case .dark:
            return DesignPalette(
                appBackground: Color(red: 0.075, green: 0.078, blue: 0.086),
                documentSurface: Color(red: 0.125, green: 0.130, blue: 0.142),
                editorSurface: Color(red: 0.095, green: 0.100, blue: 0.110),
                primaryText: Color(red: 0.840, green: 0.845, blue: 0.860),
                secondaryText: Color(red: 0.630, green: 0.645, blue: 0.670),
                mutedText: Color(red: 0.520, green: 0.540, blue: 0.565),
                border: Color.white.opacity(0.090),
                subtleBorder: Color.white.opacity(0.055),
                codeBackground: Color(red: 0.080, green: 0.085, blue: 0.095),
                inlineCodeBackground: Color.white.opacity(0.070),
                quoteBackground: Color.white.opacity(0.038),
                toolbarControlBackground: Color.white.opacity(0.060),
                badgeBackground: Color.white.opacity(0.070),
                cardShadow: Color.black.opacity(0.200),
                annotationHighlight: Color(red: 0.78, green: 0.61, blue: 0.24).opacity(0.22),
                annotationUnderline: Color(red: 0.82, green: 0.72, blue: 0.46).opacity(0.70),
                annotationControlBackground: Color.white.opacity(0.080)
            )
        default:
            return DesignPalette(
                appBackground: Color(red: 0.962, green: 0.960, blue: 0.952),
                documentSurface: Color(red: 0.995, green: 0.994, blue: 0.990),
                editorSurface: Color(red: 0.948, green: 0.950, blue: 0.946),
                primaryText: Color(red: 0.180, green: 0.178, blue: 0.170),
                secondaryText: Color(red: 0.420, green: 0.420, blue: 0.400),
                mutedText: Color(red: 0.560, green: 0.555, blue: 0.530),
                border: Color.black.opacity(0.095),
                subtleBorder: Color.black.opacity(0.055),
                codeBackground: Color(red: 0.925, green: 0.928, blue: 0.922),
                inlineCodeBackground: Color.black.opacity(0.065),
                quoteBackground: Color.black.opacity(0.030),
                toolbarControlBackground: Color.white.opacity(0.420),
                badgeBackground: Color.black.opacity(0.055),
                cardShadow: Color.black.opacity(0.070),
                annotationHighlight: Color(red: 1.00, green: 0.88, blue: 0.40).opacity(0.28),
                annotationUnderline: Color(red: 0.72, green: 0.62, blue: 0.34).opacity(0.70),
                annotationControlBackground: Color.white.opacity(0.720)
            )
        }
    }
}
