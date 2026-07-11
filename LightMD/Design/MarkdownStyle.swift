import SwiftUI

enum MarkdownStyle {
    static let bodyFont = Font.system(size: 16.5)
    static let bodyLineSpacing: CGFloat = 6
    static let listSpacing: CGFloat = 9
    static let blockSpacing: CGFloat = 16
    static let codeFont = Font.system(size: 14, design: .monospaced)
    static let editorFont = Font.system(size: 15, design: .monospaced)

    static func headingFont(for level: Int) -> Font {
        switch level {
        case 1:
            return .system(size: 32, weight: .semibold)
        case 2:
            return .system(size: 25, weight: .semibold)
        case 3:
            return .system(size: 20, weight: .semibold)
        default:
            return .system(size: 17, weight: .semibold)
        }
    }

    static func headingTopPadding(for level: Int) -> CGFloat {
        switch level {
        case 1:
            return 2
        case 2:
            return 18
        case 3:
            return 12
        default:
            return 8
        }
    }

    static func headingBottomPadding(for level: Int) -> CGFloat {
        level == 1 ? 4 : 0
    }
}
