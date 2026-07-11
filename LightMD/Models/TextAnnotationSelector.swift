import Foundation

struct TextAnnotationSelector: Codable, Hashable {
    var exact: String
    var prefix: String?
    var suffix: String?
    var startOffset: Int
    var endOffset: Int
}
