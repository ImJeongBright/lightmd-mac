import Foundation

struct MarkdownHeading: Identifiable, Hashable {
    let id: String
    let level: Int
    let title: String
    let index: Int
}
