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
            
            let statusMap = GitStatusService.getStatus(for: url)
            let rootNodeWithGit = applyGitStatus(to: rootNode, statusMap: statusMap, rootURL: url)
            
            self.treesByRootURL[url] = [rootNodeWithGit]
            self.filesByRootURL[url] = files
            self.indicesByRootURL[url] = fileIndex
        } catch {
            print("Failed to scan folder \(url): \(error)")
        }
    }
    
    private func applyGitStatus(to node: FileTreeNode, statusMap: [String: GitStatus], rootURL: URL) -> FileTreeNode {
        var newNode = node
        let path = node.url.path
        let rootPath = rootURL.path
        if path.hasPrefix(rootPath) {
            var relPath = String(path.dropFirst(rootPath.count))
            if relPath.hasPrefix("/") {
                relPath = String(relPath.dropFirst())
            }
            if let status = statusMap[relPath] {
                newNode.gitStatus = status
            }
        }
        
        newNode.children = newNode.children.map { applyGitStatus(to: $0, statusMap: statusMap, rootURL: rootURL) }
        
        if newNode.isDirectory {
            if newNode.children.contains(where: { $0.gitStatus != .normal }) {
                newNode.gitStatus = .modified
            }
        }
        
        return newNode
    }
}
