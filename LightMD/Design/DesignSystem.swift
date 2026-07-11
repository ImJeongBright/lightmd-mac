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
                appBackground: Color(red: 0.125, green: 0.125, blue: 0.125), // Sidebar #202020
                documentSurface: Color(red: 0.098, green: 0.098, blue: 0.098), // Editor #191919
                editorSurface: Color(red: 0.098, green: 0.098, blue: 0.098),
                primaryText: Color(red: 1.0, green: 1.0, blue: 1.0).opacity(0.81), // Notion Dark text
                secondaryText: Color(red: 0.608, green: 0.608, blue: 0.608), // Muted dark text #9B9B9B
                mutedText: Color(red: 0.450, green: 0.450, blue: 0.450),
                border: Color.white.opacity(0.090),
                subtleBorder: Color.white.opacity(0.055),
                codeBackground: Color.white.opacity(0.05),
                inlineCodeBackground: Color.white.opacity(0.05),
                quoteBackground: Color.clear,
                toolbarControlBackground: Color.white.opacity(0.060),
                badgeBackground: Color.white.opacity(0.070),
                cardShadow: Color.clear, // No shadows
                annotationHighlight: Color(red: 0.78, green: 0.61, blue: 0.24).opacity(0.22),
                annotationUnderline: Color(red: 0.82, green: 0.72, blue: 0.46).opacity(0.70),
                annotationControlBackground: Color.white.opacity(0.080)
            )
        default:
            return DesignPalette(
                appBackground: Color(red: 0.968, green: 0.968, blue: 0.960), // Sidebar #F7F7F5
                documentSurface: Color.white, // Editor pure white
                editorSurface: Color.white,
                primaryText: Color(red: 0.215, green: 0.207, blue: 0.184), // Notion #37352F
                secondaryText: Color(red: 0.470, green: 0.466, blue: 0.454), // Subtle #787774
                mutedText: Color(red: 0.560, green: 0.555, blue: 0.530),
                border: Color.black.opacity(0.095),
                subtleBorder: Color.black.opacity(0.055),
                codeBackground: Color(red: 0.956, green: 0.956, blue: 0.956), // F4F4F4
                inlineCodeBackground: Color(red: 0.956, green: 0.956, blue: 0.956),
                quoteBackground: Color.clear,
                toolbarControlBackground: Color.black.opacity(0.04),
                badgeBackground: Color.black.opacity(0.055),
                cardShadow: Color.clear, // No shadows
                annotationHighlight: Color(red: 1.00, green: 0.88, blue: 0.40).opacity(0.28),
                annotationUnderline: Color(red: 0.72, green: 0.62, blue: 0.34).opacity(0.70),
                annotationControlBackground: Color.white.opacity(0.9)
            )
        }
    }
}
