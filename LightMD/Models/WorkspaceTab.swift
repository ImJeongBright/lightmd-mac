import Foundation

struct WorkspaceTab: Identifiable, Hashable, Codable {
    var id: UUID
    var rootFolderURL: URL
    var title: String
    var icon: String?
    var selectedFileURL: URL?
    var createdAt: Date
    var lastAccessedAt: Date
    
    init(id: UUID = UUID(), rootFolderURL: URL, icon: String? = nil, selectedFileURL: URL? = nil) {
        self.id = id
        self.rootFolderURL = rootFolderURL
        self.title = rootFolderURL.lastPathComponent
        self.icon = icon
        self.selectedFileURL = selectedFileURL
        self.createdAt = Date()
        self.lastAccessedAt = Date()
    }
}
