import Foundation

struct QuickOpenItem: Identifiable, Hashable {
    let id = UUID()
    let fileURL: URL
    let title: String
    let relativePath: String
}
