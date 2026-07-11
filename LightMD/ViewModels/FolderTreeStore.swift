import Foundation
import Combine

@MainActor
final class FolderTreeStore: ObservableObject {
    @Published private(set) var treesByRootURL: [URL: [FileTreeNode]] = [:]
    @Published private(set) var filesByRootURL: [URL: [FolderDocument]] = [:]
    @Published private(set) var indicesByRootURL: [URL: MarkdownFileIndex] = [:]
    
    func tree(for url: URL) -> [FileTreeNode]? {
        treesByRootURL[url]
    }
    
    func files(for url: URL) -> [FolderDocument]? {
        filesByRootURL[url]
    }
    
    func index(for url: URL) -> MarkdownFileIndex? {
        indicesByRootURL[url]
    }
    
    func loadTree(for url: URL) {
        if treesByRootURL[url] != nil { return } // Already cached
        refreshTree(for: url)
    }
    
    func refreshTree(for url: URL) {
        do {
            // Need a way to begin access to security scoped bookmarks if necessary
            // For now, assuming URL is accessible or previously authorized
            let rootNode = try FolderScanner.scan(rootURL: url, maxDepth: 5)
            let files = FolderScanner.flattenMarkdownFiles(from: rootNode).map { FolderDocument(url: $0) }
            
            let fileIndex = MarkdownFileIndex()
            fileIndex.rebuild(rootFolderURL: url, markdownFiles: files)
            
            self.treesByRootURL[url] = [rootNode]
            self.filesByRootURL[url] = files
            self.indicesByRootURL[url] = fileIndex
        } catch {
            print("Failed to scan folder \(url): \(error)")
        }
    }
}
