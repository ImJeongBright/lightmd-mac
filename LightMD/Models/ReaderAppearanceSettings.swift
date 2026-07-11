import Foundation
import SwiftUI

enum FontFamily: String, CaseIterable, Codable {
    case system = "System"
    case serif = "Serif"
    case sansSerif = "Sans-Serif"
    case monospace = "Monospace"
    
    var cssValue: String {
        switch self {
        case .system: return "-apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif"
        case .serif: return "Georgia, Cambria, \"Times New Roman\", Times, serif"
        case .sansSerif: return "Helvetica, Arial, sans-serif"
        case .monospace: return "ui-monospace, SFMono-Regular, Consolas, \"Liberation Mono\", Menlo, monospace"
        }
    }
}

enum LineSpacing: String, CaseIterable, Codable {
    case tight = "Tight"
    case normal = "Normal"
    case relaxed = "Relaxed"
    
    var cssValue: Double {
        switch self {
        case .tight: return 1.4
        case .normal: return 1.6
        case .relaxed: return 1.8
        }
    }
}

enum DocumentTheme: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case sepia = "Sepia"
    case solarizedDark = "Solarized"
    
    var label: String { self.rawValue }
}

enum ContentWidth: String, CaseIterable, Codable {
    case narrow = "Narrow"
    case medium = "Medium"
    case wide = "Wide"
    case full = "Full"
    
    var cssValue: String {
        switch self {
        case .narrow: return "600px"
        case .medium: return "800px"
        case .wide: return "1200px"
        case .full: return "95%"
        }
    }
}

@MainActor
final class ReaderAppearanceSettings: ObservableObject {
    @AppStorage("ReaderAppearanceSettingsData") private var settingsData: Data = Data()
    
    struct Settings: Codable, Equatable {
        var fontFamily: FontFamily = .system
        var fontSizeBase: Int = 15 // base pixel size
        var lineSpacing: LineSpacing = .normal
        var documentTheme: DocumentTheme = .system
        var contentWidth: ContentWidth = .medium
    }
    
    @Published var current: Settings {
        didSet {
            save()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "ReaderAppearanceSettingsData"),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            self.current = decoded
        } else {
            self.current = Settings()
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(current) {
            settingsData = encoded
        }
    }
    
    // Actions
    func increaseFontSize() {
        if current.fontSizeBase < 30 {
            current.fontSizeBase += 1
        }
    }
    
    func decreaseFontSize() {
        if current.fontSizeBase > 10 {
            current.fontSizeBase -= 1
        }
    }
    
    func reset() {
        current = Settings()
    }
}
