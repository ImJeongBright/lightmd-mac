import Foundation

enum AnnotationType: String, Codable, CaseIterable {
    case highlight
    case underline
    case memo

    case textColor

    var title: String {
        switch self {
        case .highlight:
            return "Highlight"
        case .underline:
            return "Underline"
        case .memo:
            return "Memo"
        case .textColor:
            return "Text Color"
        }
    }
}

struct MarkdownAnnotation: Identifiable, Codable, Hashable {
    var id: UUID
    var selector: TextAnnotationSelector
    var type: AnnotationType
    var memo: String?
    var colorHex: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        selector: TextAnnotationSelector,
        type: AnnotationType,
        memo: String? = nil,
        colorHex: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.selector = selector
        self.type = type
        self.memo = memo
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
