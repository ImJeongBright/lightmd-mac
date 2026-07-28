import Foundation

struct WorkspaceSearchResult: Identifiable, Hashable {
    let id = UUID()
    let fileURL: URL
    let title: String
    let relativePath: String
    let lineNumber: Int?
    let snippet: String
    
    // Using a Range<String.Index> doesn't map well through Codable/Hashable without extra work
    // So we just store the matched string and the start/end offsets.
    let matchStartOffset: Int
    let matchEndOffset: Int
}
