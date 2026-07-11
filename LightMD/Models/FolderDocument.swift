import Foundation

struct FolderDocument: Identifiable, Hashable {
    let url: URL

    var id: String {
        url.standardizedFileURL.path
    }

    var title: String {
        url.lastPathComponent
    }
}
