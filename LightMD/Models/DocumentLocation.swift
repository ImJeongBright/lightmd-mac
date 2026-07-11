import Foundation

struct DocumentLocation: Hashable, Codable {
    let fileURL: URL
    var anchor: String?
    var scrollOffset: Double?

    init(fileURL: URL, headingID: String? = nil, scrollOffset: Double? = nil) {
        self.fileURL = fileURL.standardizedFileURL
        self.anchor = headingID
        self.scrollOffset = scrollOffset
    }

    var headingID: String? {
        get { anchor }
        set { anchor = newValue }
    }

    var filePath: String {
        fileURL.standardizedFileURL.path
    }

    func isSameDocument(as other: DocumentLocation) -> Bool {
        filePath == other.filePath
    }

    func isSameLocation(as other: DocumentLocation) -> Bool {
        filePath == other.filePath &&
            headingID == other.headingID &&
            scrollOffset == other.scrollOffset
    }
}
