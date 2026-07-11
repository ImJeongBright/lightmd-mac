import Foundation

struct DocumentWindowRequest: Codable, Hashable {
    var filePath: String?
    var rootFolderPath: String?
    var anchor: String?

    init(fileURL: URL? = nil, rootFolderURL: URL? = nil, anchor: String? = nil) {
        self.filePath = fileURL?.standardizedFileURL.path
        self.rootFolderPath = rootFolderURL?.standardizedFileURL.path
        self.anchor = anchor
    }

    var fileURL: URL? {
        filePath.map { URL(fileURLWithPath: $0).standardizedFileURL }
    }

    var rootFolderURL: URL? {
        rootFolderPath.map { URL(fileURLWithPath: $0).standardizedFileURL }
    }
}
