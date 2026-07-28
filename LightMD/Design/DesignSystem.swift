import SwiftUI

// MARK: - Enums

enum AccentPreset: String, CaseIterable, Codable, Identifiable {
    case blue, indigo, green, orange, rose, purple

    var id: String { rawValue }

    var label: String {
        switch self {
        case .blue: return "Blue"
        case .indigo: return "Indigo"
        case .green: return "Green"
        case .orange: return "Orange"
        case .rose: return "Rose"
        case .purple: return "Purple"
        }
    }

    var color: Color {
        switch self {
        case .blue:   return Color(hex: 0x5B6FA8)
        case .indigo: return Color(hex: 0x5856D6)
        case .green:  return Color(hex: 0x5A8A5C)
        case .orange: return Color(hex: 0xC47D2E)
        case .rose:   return Color(hex: 0xC25B72)
        case .purple: return Color(hex: 0x8B5FC7)
        }
    }

    var softColor: Color {
        switch self {
        case .blue:   return Color(hex: 0xE6EAF5)
        case .indigo: return Color(hex: 0xEAE9FA)
        case .green:  return Color(hex: 0xE4EDE4)
        case .orange: return Color(hex: 0xF5EDE1)
        case .rose:   return Color(hex: 0xF5E4EA)
        case .purple: return Color(hex: 0xEDE4F5)
        }
    }

    var darkColor: Color {
        switch self {
        case .blue:   return Color(hex: 0x7B93D4)
        case .indigo: return Color(hex: 0x8583F0)
        case .green:  return Color(hex: 0x7AAF7C)
        case .orange: return Color(hex: 0xDEA256)
        case .rose:   return Color(hex: 0xDE7E93)
        case .purple: return Color(hex: 0xAE84E0)
        }
    }

    var darkSoftColor: Color {
        switch self {
        case .blue:   return Color(hex: 0x2E3548)
        case .indigo: return Color(hex: 0x2E2D4A)
        case .green:  return Color(hex: 0x2A382A)
        case .orange: return Color(hex: 0x3D3226)
        case .rose:   return Color(hex: 0x3D2A32)
        case .purple: return Color(hex: 0x332A42)
        }
    }

    var hexString: String {
        switch self {
        case .blue:   return "#5B6FA8"
        case .indigo: return "#5856D6"
        case .green:  return "#5A8A5C"
        case .orange: return "#C47D2E"
        case .rose:   return "#C25B72"
        case .purple: return "#8B5FC7"
        }
    }

    var darkHexString: String {
        switch self {
        case .blue:   return "#7B93D4"
        case .indigo: return "#8583F0"
        case .green:  return "#7AAF7C"
        case .orange: return "#DEA256"
        case .rose:   return "#DE7E93"
        case .purple: return "#AE84E0"
        }
    }
}

enum ReaderTheme: String, CaseIterable, Codable, Identifiable {
    case clean, paper, mist, sage, dark, midnight

    var id: String { rawValue }

    var label: String {
        switch self {
        case .clean:    return "Clean"
        case .paper:    return "Paper"
        case .mist:     return "Mist"
        case .sage:     return "Sage"
        case .dark:     return "Dark"
        case .midnight: return "Midnight"
        }
    }

    var isDark: Bool {
        switch self {
        case .dark, .midnight: return true
        default: return false
        }
    }
}

enum TextColorPreset: String, CaseIterable, Codable, Identifiable {
    case charcoal, inkBlack, deepNavy, warmBrown, softWhite

    var id: String { rawValue }

    var label: String {
        switch self {
        case .charcoal:  return "Charcoal"
        case .inkBlack:  return "Ink Black"
        case .deepNavy:  return "Deep Navy"
        case .warmBrown: return "Warm Brown"
        case .softWhite: return "Soft White"
        }
    }

    var hexString: String {
        switch self {
        case .charcoal:  return "#292824"
        case .inkBlack:  return "#1A1A1A"
        case .deepNavy:  return "#1E2A3A"
        case .warmBrown: return "#3B2E1E"
        case .softWhite: return "#E7E5DF"
        }
    }

    var color: Color {
        switch self {
        case .charcoal:  return Color(hex: 0x292824)
        case .inkBlack:  return Color(hex: 0x1A1A1A)
        case .deepNavy:  return Color(hex: 0x1E2A3A)
        case .warmBrown: return Color(hex: 0x3B2E1E)
        case .softWhite: return Color(hex: 0xE7E5DF)
        }
    }

    /// Suitable for light theme backgrounds
    var isSuitableForLight: Bool {
        switch self {
        case .softWhite: return false
        default: return true
        }
    }

    /// Suitable for dark theme backgrounds
    var isSuitableForDark: Bool {
        switch self {
        case .charcoal, .inkBlack, .deepNavy, .warmBrown: return false
        case .softWhite: return true
        }
    }
}

enum HighlightPreset: String, CaseIterable, Codable, Identifiable {
    case yellow, green, blue, pink, purple, orange

    var id: String { rawValue }

    var label: String {
        switch self {
        case .yellow: return "Yellow"
        case .green:  return "Green"
        case .blue:   return "Blue"
        case .pink:   return "Pink"
        case .purple: return "Purple"
        case .orange: return "Orange"
        }
    }

    var lightCSS: String {
        switch self {
        case .yellow: return "rgba(255, 227, 120, 0.40)"
        case .green:  return "rgba(152, 211, 152, 0.35)"
        case .blue:   return "rgba(148, 196, 240, 0.35)"
        case .pink:   return "rgba(240, 168, 192, 0.35)"
        case .purple: return "rgba(196, 168, 232, 0.35)"
        case .orange: return "rgba(248, 200, 140, 0.38)"
        }
    }

    var darkCSS: String {
        switch self {
        case .yellow: return "rgba(255, 214, 10, 0.25)"
        case .green:  return "rgba(90, 200, 90, 0.20)"
        case .blue:   return "rgba(80, 160, 240, 0.22)"
        case .pink:   return "rgba(240, 100, 140, 0.22)"
        case .purple: return "rgba(160, 100, 220, 0.22)"
        case .orange: return "rgba(240, 160, 50, 0.25)"
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .yellow: return Color(red: 1.00, green: 0.89, blue: 0.47).opacity(0.40)
        case .green:  return Color(red: 0.60, green: 0.83, blue: 0.60).opacity(0.35)
        case .blue:   return Color(red: 0.58, green: 0.77, blue: 0.94).opacity(0.35)
        case .pink:   return Color(red: 0.94, green: 0.66, blue: 0.75).opacity(0.35)
        case .purple: return Color(red: 0.77, green: 0.66, blue: 0.91).opacity(0.35)
        case .orange: return Color(red: 0.97, green: 0.78, blue: 0.55).opacity(0.38)
        }
    }
}

// MARK: - AppColors (Semantic Color Token Container)

struct AppColors {
    let appBackground: Color
    let sidebarBackground: Color
    let readerBackground: Color
    let secondarySurface: Color

    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color

    let border: Color
    let divider: Color
    let hoverBackground: Color
    let selectedBackground: Color

    let accent: Color
    let accentSoft: Color

    let codeBackground: Color
    let inlineCodeBackground: Color
    let tableHeaderBackground: Color
    let blockquoteBackground: Color

    // Annotation
    let annotationHighlight: Color
    let annotationUnderline: Color
    let annotationControlBackground: Color

    // CSS hex strings for WKWebView
    let cssAppBg: String
    let cssReaderBg: String
    let cssPrimaryText: String
    let cssSecondaryText: String
    let cssBorder: String
    let cssDivider: String
    let cssSecondarySurface: String
    let cssAccent: String
    let cssAccentSoft: String
    let cssCodeBg: String
    let cssTableHeaderBg: String
    let cssBlockquoteBg: String
    let cssHighlightBg: String
    let cssUnderlineColor: String
    let cssMemoBg: String
}

// MARK: - DesignSystem

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

    // MARK: - Resolve colors for current theme + scheme

    static func colors(
        sceneThemeID: SceneThemeID
    ) -> AppColors {
        let theme = SceneTheme.theme(for: sceneThemeID)
        return AppColors(
            appBackground: theme.appBackground,
            sidebarBackground: theme.sidebarBackground,
            readerBackground: theme.readerBackground,
            secondarySurface: theme.secondarySurface,
            primaryText: theme.primaryText,
            secondaryText: theme.secondaryText,
            tertiaryText: theme.tertiaryText,
            border: theme.border,
            divider: theme.divider,
            hoverBackground: theme.hoverBackground,
            selectedBackground: theme.selectedBackground,
            accent: theme.accent,
            accentSoft: theme.accentSoft,
            codeBackground: theme.codeBackground,
            inlineCodeBackground: theme.inlineCodeBackground,
            tableHeaderBackground: theme.tableHeaderBackground,
            blockquoteBackground: theme.blockquoteBackground,
            annotationHighlight: theme.accent.opacity(0.3),
            annotationUnderline: theme.accent.opacity(0.7),
            annotationControlBackground: theme.readerBackground.opacity(0.9),
            cssAppBg: theme.cssAppBg,
            cssReaderBg: theme.cssReaderBg,
            cssPrimaryText: theme.cssPrimaryText,
            cssSecondaryText: theme.cssSecondaryText,
            cssBorder: theme.cssBorder,
            cssDivider: theme.cssDivider,
            cssSecondarySurface: theme.cssSecondarySurface,
            cssAccent: theme.cssAccent,
            cssAccentSoft: theme.cssAccentSoft,
            cssCodeBg: theme.cssCodeBg,
            cssTableHeaderBg: theme.cssTableHeaderBg,
            cssBlockquoteBg: theme.cssBlockquoteBg,
            cssHighlightBg: theme.cssHighlightBg,
            cssUnderlineColor: theme.cssAccent,
            cssMemoBg: theme.cssAccentSoft
        )
    }

    // MARK: - Legacy compatibility (deprecated, still used during migration)
}

// MARK: - Legacy DesignPalette (kept for backward compat)

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

// MARK: - Color Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
