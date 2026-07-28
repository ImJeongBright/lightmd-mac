import SwiftUI
import UniformTypeIdentifiers

enum SceneThemeID: String, CaseIterable, Codable, Identifiable {
    case cleanCanvas
    case warmLibrary
    case aurora
    case midnightNebula
    case blueprint
    case forestTerminal
    case sepia
    case nord
    case solarizedLight
    case solarizedDark
    case gruvboxLight
    case dracula
    case catppuccinLatte
    case catppuccinMocha
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .cleanCanvas: return "Clean Canvas"
        case .warmLibrary: return "Warm Library"
        case .aurora: return "Aurora"
        case .midnightNebula: return "Midnight Nebula"
        case .blueprint: return "Blueprint"
        case .forestTerminal: return "Forest Terminal"
        case .sepia: return "Sepia"
        case .nord: return "Nord"
        case .solarizedLight: return "Solarized Light"
        case .solarizedDark: return "Solarized Dark"
        case .gruvboxLight: return "Gruvbox Light"
        case .dracula: return "Dracula"
        case .catppuccinLatte: return "Catppuccin Latte"
        case .catppuccinMocha: return "Catppuccin Mocha"
        }
    }
}

enum ThemeBackgroundType: String, Codable {
    case none
    case aurora
    case stars
    case blueprint
    case forest
    case warmNoise
}

struct SceneTheme: Identifiable {
    let id: SceneThemeID
    let displayName: String
    
    let isDark: Bool
    let backgroundType: ThemeBackgroundType
    
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
    
    // CSS Strings
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
    
    var readerOpacity: Double {
        switch id {
        case .aurora, .midnightNebula, .blueprint, .forestTerminal: return 0.85
        case .warmLibrary: return 0.95
        default: return 1.0
        }
    }
}
