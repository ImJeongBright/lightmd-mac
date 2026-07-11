import Foundation

struct MarkdownDocument: Identifiable {
    let id = UUID()
    let url: URL
    var text: String
    var originalText: String

    init(url: URL, text: String) {
        self.url = url
        self.text = text
        self.originalText = text
    }

    var title: String {
        url.lastPathComponent
    }

    var isDirty: Bool {
        text != originalText
    }
}
