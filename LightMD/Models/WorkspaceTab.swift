import Foundation

struct WorkspaceTab: Identifiable, Hashable, Codable {
    var id: UUID
    var rootFolderURL: URL
    var title: String
    var selectedFileURL: URL?
    var createdAt: Date
    var lastAccessedAt: Date
    
    init(id: UUID = UUID(), rootFolderURL: URL, selectedFileURL: URL? = nil) {
        self.id = id
        self.rootFolderURL = rootFolderURL
        self.title = rootFolderURL.lastPathComponent
        self.selectedFileURL = selectedFileURL
        self.createdAt = Date()
        self.lastAccessedAt = Date()
    }
}
