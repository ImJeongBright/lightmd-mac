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
        theme: ReaderTheme = .clean,
        accent: AccentPreset = .blue,
        textColor: TextColorPreset = .charcoal,
        highlight: HighlightPreset = .yellow,
        colorScheme: ColorScheme
    ) -> AppColors {
        let effectiveTheme: ReaderTheme
        if theme == .clean || theme == .paper || theme == .mist || theme == .sage {
            effectiveTheme = colorScheme == .dark ? .dark : theme
        } else {
            effectiveTheme = theme
        }

        switch effectiveTheme {
        case .clean:
            return cleanTheme(accent: accent, textColor: textColor, highlight: highlight)
        case .paper:
            return paperTheme(accent: accent, textColor: textColor, highlight: highlight)
        case .mist:
            return mistTheme(accent: accent, textColor: textColor, highlight: highlight)
        case .sage:
            return sageTheme(accent: accent, textColor: textColor, highlight: highlight)
        case .dark:
            return darkTheme(accent: accent, highlight: highlight)
        case .midnight:
            return midnightTheme(accent: accent, highlight: highlight)
        }
    }

    // MARK: - Light Themes

    private static func cleanTheme(accent: AccentPreset, textColor: TextColorPreset, highlight: HighlightPreset) -> AppColors {
        let primaryText = textColor.isSuitableForLight ? textColor.color : TextColorPreset.charcoal.color
        return AppColors(
            appBackground:       Color(hex: 0xF7F6F2),
            sidebarBackground:   Color(hex: 0xF1F0EC),
            readerBackground:    Color(hex: 0xFCFBF8),
            secondarySurface:    Color(hex: 0xF3F1EC),
            primaryText:         primaryText,
            secondaryText:       Color(hex: 0x706E68),
            tertiaryText:        Color(hex: 0x96938B),
            border:              Color(hex: 0xE4E1DA),
            divider:             Color(hex: 0xE8E5DE),
            hoverBackground:     Color(hex: 0xECEAE4),
            selectedBackground:  accent.softColor,
            accent:              accent.color,
            accentSoft:          accent.softColor,
            codeBackground:      Color(hex: 0xF3F1EC),
            inlineCodeBackground:Color(hex: 0xF0EDE6),
            tableHeaderBackground:Color(hex: 0xF1EFEA),
            blockquoteBackground:Color(hex: 0xF5F3EE),
            annotationHighlight: highlight.swiftUIColor,
            annotationUnderline: Color(red: 0.72, green: 0.62, blue: 0.34).opacity(0.70),
            annotationControlBackground: Color.white.opacity(0.9),
            cssAppBg: "#F7F6F2", cssReaderBg: "#FCFBF8",
            cssPrimaryText: textColor.isSuitableForLight ? textColor.hexString : "#292824",
            cssSecondaryText: "#706E68",
            cssBorder: "#E4E1DA", cssDivider: "#E8E5DE",
            cssSecondarySurface: "#F3F1EC",
            cssAccent: accent.hexString, cssAccentSoft: "#E6EAF5",
            cssCodeBg: "#F3F1EC", cssTableHeaderBg: "#F1EFEA",
            cssBlockquoteBg: "#F5F3EE",
            cssHighlightBg: highlight.lightCSS,
            cssUnderlineColor: "rgba(184, 158, 86, 0.70)",
            cssMemoBg: "rgba(90, 200, 120, 0.15)"
        )
    }

    private static func paperTheme(accent: AccentPreset, textColor: TextColorPreset, highlight: HighlightPreset) -> AppColors {
        let primaryText = textColor.isSuitableForLight ? textColor.color : TextColorPreset.warmBrown.color
        return AppColors(
            appBackground:       Color(hex: 0xF0E8D8),
            sidebarBackground:   Color(hex: 0xEBE3D2),
            readerBackground:    Color(hex: 0xF5EFE2),
            secondarySurface:    Color(hex: 0xEAE2D0),
            primaryText:         primaryText,
            secondaryText:       Color(hex: 0x7A6F5E),
            tertiaryText:        Color(hex: 0x9E937F),
            border:              Color(hex: 0xD8CDB8),
            divider:             Color(hex: 0xDDD2BD),
            hoverBackground:     Color(hex: 0xE5DCCA),
            selectedBackground:  accent.softColor,
            accent:              accent.color,
            accentSoft:          accent.softColor,
            codeBackground:      Color(hex: 0xEAE2D0),
            inlineCodeBackground:Color(hex: 0xE6DDC9),
            tableHeaderBackground:Color(hex: 0xE8E0CE),
            blockquoteBackground:Color(hex: 0xEDE5D5),
            annotationHighlight: highlight.swiftUIColor,
            annotationUnderline: Color(red: 0.72, green: 0.62, blue: 0.34).opacity(0.70),
            annotationControlBackground: Color(hex: 0xF5EFE2).opacity(0.9),
            cssAppBg: "#F0E8D8", cssReaderBg: "#F5EFE2",
            cssPrimaryText: textColor.isSuitableForLight ? textColor.hexString : "#3B2E1E",
            cssSecondaryText: "#7A6F5E",
            cssBorder: "#D8CDB8", cssDivider: "#DDD2BD",
            cssSecondarySurface: "#EAE2D0",
            cssAccent: accent.hexString, cssAccentSoft: "#E6EAF5",
            cssCodeBg: "#EAE2D0", cssTableHeaderBg: "#E8E0CE",
            cssBlockquoteBg: "#EDE5D5",
            cssHighlightBg: highlight.lightCSS,
            cssUnderlineColor: "rgba(184, 140, 60, 0.70)",
            cssMemoBg: "rgba(90, 180, 100, 0.15)"
        )
    }

    private static func mistTheme(accent: AccentPreset, textColor: TextColorPreset, highlight: HighlightPreset) -> AppColors {
        let primaryText = textColor.isSuitableForLight ? textColor.color : TextColorPreset.charcoal.color
        return AppColors(
            appBackground:       Color(hex: 0xF0F4F8),
            sidebarBackground:   Color(hex: 0xEAEFF5),
            readerBackground:    Color(hex: 0xF6F9FC),
            secondarySurface:    Color(hex: 0xECF0F5),
            primaryText:         primaryText,
            secondaryText:       Color(hex: 0x6A7280),
            tertiaryText:        Color(hex: 0x92969E),
            border:              Color(hex: 0xDCE2EA),
            divider:             Color(hex: 0xE0E5ED),
            hoverBackground:     Color(hex: 0xE4E9F0),
            selectedBackground:  accent.softColor,
            accent:              accent.color,
            accentSoft:          accent.softColor,
            codeBackground:      Color(hex: 0xECF0F5),
            inlineCodeBackground:Color(hex: 0xE8ECF2),
            tableHeaderBackground:Color(hex: 0xEAEEF4),
            blockquoteBackground:Color(hex: 0xEFF3F8),
            annotationHighlight: highlight.swiftUIColor,
            annotationUnderline: Color(red: 0.55, green: 0.60, blue: 0.72).opacity(0.70),
            annotationControlBackground: Color.white.opacity(0.9),
            cssAppBg: "#F0F4F8", cssReaderBg: "#F6F9FC",
            cssPrimaryText: textColor.isSuitableForLight ? textColor.hexString : "#292824",
            cssSecondaryText: "#6A7280",
            cssBorder: "#DCE2EA", cssDivider: "#E0E5ED",
            cssSecondarySurface: "#ECF0F5",
            cssAccent: accent.hexString, cssAccentSoft: "#E6EAF5",
            cssCodeBg: "#ECF0F5", cssTableHeaderBg: "#EAEEF4",
            cssBlockquoteBg: "#EFF3F8",
            cssHighlightBg: highlight.lightCSS,
            cssUnderlineColor: "rgba(140, 155, 184, 0.70)",
            cssMemoBg: "rgba(80, 190, 120, 0.15)"
        )
    }

    private static func sageTheme(accent: AccentPreset, textColor: TextColorPreset, highlight: HighlightPreset) -> AppColors {
        let primaryText = textColor.isSuitableForLight ? textColor.color : TextColorPreset.charcoal.color
        return AppColors(
            appBackground:       Color(hex: 0xF0F4F0),
            sidebarBackground:   Color(hex: 0xEAEFEA),
            readerBackground:    Color(hex: 0xF6FAF6),
            secondarySurface:    Color(hex: 0xECF1EC),
            primaryText:         primaryText,
            secondaryText:       Color(hex: 0x6A7A6A),
            tertiaryText:        Color(hex: 0x8E9E8E),
            border:              Color(hex: 0xD8E2D8),
            divider:             Color(hex: 0xDDE6DD),
            hoverBackground:     Color(hex: 0xE2EBE2),
            selectedBackground:  accent.softColor,
            accent:              accent.color,
            accentSoft:          accent.softColor,
            codeBackground:      Color(hex: 0xECF1EC),
            inlineCodeBackground:Color(hex: 0xE6EDE6),
            tableHeaderBackground:Color(hex: 0xEAEFEA),
            blockquoteBackground:Color(hex: 0xEEF4EE),
            annotationHighlight: highlight.swiftUIColor,
            annotationUnderline: Color(red: 0.55, green: 0.68, blue: 0.55).opacity(0.70),
            annotationControlBackground: Color.white.opacity(0.9),
            cssAppBg: "#F0F4F0", cssReaderBg: "#F6FAF6",
            cssPrimaryText: textColor.isSuitableForLight ? textColor.hexString : "#292824",
            cssSecondaryText: "#6A7A6A",
            cssBorder: "#D8E2D8", cssDivider: "#DDE6DD",
            cssSecondarySurface: "#ECF1EC",
            cssAccent: accent.hexString, cssAccentSoft: "#E4EDE4",
            cssCodeBg: "#ECF1EC", cssTableHeaderBg: "#EAEEF4",
            cssBlockquoteBg: "#EEF4EE",
            cssHighlightBg: highlight.lightCSS,
            cssUnderlineColor: "rgba(140, 175, 140, 0.70)",
            cssMemoBg: "rgba(80, 190, 100, 0.15)"
        )
    }

    // MARK: - Dark Themes

    private static func darkTheme(accent: AccentPreset, highlight: HighlightPreset) -> AppColors {
        return AppColors(
            appBackground:       Color(hex: 0x1D1F24),
            sidebarBackground:   Color(hex: 0x202229),
            readerBackground:    Color(hex: 0x1D1F24),
            secondarySurface:    Color(hex: 0x272A31),
            primaryText:         Color(hex: 0xE7E5DF),
            secondaryText:       Color(hex: 0xA5A39D),
            tertiaryText:        Color(hex: 0x6E6C66),
            border:              Color(hex: 0x32353D),
            divider:             Color(hex: 0x2E3138),
            hoverBackground:     Color(hex: 0x2E3138),
            selectedBackground:  accent.darkSoftColor,
            accent:              accent.darkColor,
            accentSoft:          accent.darkSoftColor,
            codeBackground:      Color(hex: 0x272A31),
            inlineCodeBackground:Color(hex: 0x2A2D34),
            tableHeaderBackground:Color(hex: 0x292C33),
            blockquoteBackground:Color(hex: 0x252830),
            annotationHighlight: Color(red: 0.78, green: 0.61, blue: 0.24).opacity(0.22),
            annotationUnderline: Color(red: 0.82, green: 0.72, blue: 0.46).opacity(0.70),
            annotationControlBackground: Color.white.opacity(0.080),
            cssAppBg: "#1D1F24", cssReaderBg: "#1D1F24",
            cssPrimaryText: "#E7E5DF", cssSecondaryText: "#A5A39D",
            cssBorder: "#32353D", cssDivider: "#2E3138",
            cssSecondarySurface: "#272A31",
            cssAccent: accent.darkHexString, cssAccentSoft: "#2E3548",
            cssCodeBg: "#272A31", cssTableHeaderBg: "#292C33",
            cssBlockquoteBg: "#252830",
            cssHighlightBg: highlight.darkCSS,
            cssUnderlineColor: "rgba(210, 184, 118, 0.70)",
            cssMemoBg: "rgba(90, 200, 120, 0.15)"
        )
    }

    private static func midnightTheme(accent: AccentPreset, highlight: HighlightPreset) -> AppColors {
        return AppColors(
            appBackground:       Color(hex: 0x141620),
            sidebarBackground:   Color(hex: 0x181A26),
            readerBackground:    Color(hex: 0x161822),
            secondarySurface:    Color(hex: 0x1E2030),
            primaryText:         Color(hex: 0xDCDAD4),
            secondaryText:       Color(hex: 0x8A8882),
            tertiaryText:        Color(hex: 0x5C5A55),
            border:              Color(hex: 0x282A36),
            divider:             Color(hex: 0x242630),
            hoverBackground:     Color(hex: 0x242630),
            selectedBackground:  accent.darkSoftColor,
            accent:              accent.darkColor,
            accentSoft:          accent.darkSoftColor,
            codeBackground:      Color(hex: 0x1E2030),
            inlineCodeBackground:Color(hex: 0x202234),
            tableHeaderBackground:Color(hex: 0x1E2030),
            blockquoteBackground:Color(hex: 0x1A1C28),
            annotationHighlight: Color(red: 0.78, green: 0.61, blue: 0.24).opacity(0.20),
            annotationUnderline: Color(red: 0.82, green: 0.72, blue: 0.46).opacity(0.65),
            annotationControlBackground: Color.white.opacity(0.060),
            cssAppBg: "#141620", cssReaderBg: "#161822",
            cssPrimaryText: "#DCDAD4", cssSecondaryText: "#8A8882",
            cssBorder: "#282A36", cssDivider: "#242630",
            cssSecondarySurface: "#1E2030",
            cssAccent: accent.darkHexString, cssAccentSoft: "#242640",
            cssCodeBg: "#1E2030", cssTableHeaderBg: "#1E2030",
            cssBlockquoteBg: "#1A1C28",
            cssHighlightBg: highlight.darkCSS,
            cssUnderlineColor: "rgba(210, 184, 118, 0.65)",
            cssMemoBg: "rgba(90, 200, 120, 0.12)"
        )
    }

    // MARK: - Legacy compatibility (deprecated, still used during migration)

    static func palette(for scheme: ColorScheme) -> DesignPalette {
        let c = colors(colorScheme: scheme)
        return DesignPalette(
            appBackground: c.sidebarBackground,
            documentSurface: c.readerBackground,
            editorSurface: c.readerBackground,
            primaryText: c.primaryText,
            secondaryText: c.secondaryText,
            mutedText: c.tertiaryText,
            border: c.border,
            subtleBorder: c.divider,
            codeBackground: c.codeBackground,
            inlineCodeBackground: c.inlineCodeBackground,
            quoteBackground: c.blockquoteBackground,
            toolbarControlBackground: c.hoverBackground,
            badgeBackground: c.secondarySurface,
            cardShadow: Color.clear,
            annotationHighlight: c.annotationHighlight,
            annotationUnderline: c.annotationUnderline,
            annotationControlBackground: c.annotationControlBackground
        )
    }
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
