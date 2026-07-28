import Foundation

struct FileTreeNode: Identifiable, Hashable {
    let id: String
    let url: URL
    let name: String
    let isDirectory: Bool
    var children: [FileTreeNode]
    var gitStatus: GitStatus

    init(url: URL, isDirectory: Bool, children: [FileTreeNode] = [], gitStatus: GitStatus = .normal) {
        let standardizedURL = url.standardizedFileURL
        self.id = standardizedURL.path
        self.url = standardizedURL
        self.name = standardizedURL.lastPathComponent
        self.isDirectory = isDirectory
        self.children = children
        self.gitStatus = gitStatus
    }

    var isMarkdownFile: Bool {
        guard !isDirectory else {
            return false
        }

        let fileExtension = url.pathExtension.lowercased()
        return fileExtension == "md" || fileExtension == "markdown"
    }
}
