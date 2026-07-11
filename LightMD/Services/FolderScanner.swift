import Foundation

enum FolderScanner {
    private static let excludedDirectoryNames: Set<String> = [
        ".git",
        ".build",
        ".swiftpm",
        "DerivedData",
        "node_modules"
    ]

    static func scan(rootURL: URL, maxDepth: Int = 5) throws -> FileTreeNode {
        let children = try scanChildren(in: rootURL.standardizedFileURL, depth: 0, maxDepth: maxDepth)
        return FileTreeNode(url: rootURL, isDirectory: true, children: children)
    }

    static func flattenMarkdownFiles(from root: FileTreeNode) -> [URL] {
        flattenMarkdownFiles(from: [root])
    }

    static func flattenMarkdownFiles(from nodes: [FileTreeNode]) -> [URL] {
        nodes.flatMap { node -> [URL] in
            if node.isMarkdownFile {
                return [node.url]
            }

            return flattenMarkdownFiles(from: node.children)
        }
    }

    private static func scanChildren(in folderURL: URL, depth: Int, maxDepth: Int) throws -> [FileTreeNode] {
        guard depth < maxDepth else {
            return []
        }

        let urls = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        let nodes = try urls.compactMap { url -> FileTreeNode? in
            let name = url.lastPathComponent

            if name.hasPrefix(".") {
                return nil
            }

            let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])

            if values.isDirectory == true {
                guard !excludedDirectoryNames.contains(name) else {
                    return nil
                }

                let children = try scanChildren(in: url, depth: depth + 1, maxDepth: maxDepth)
                return children.isEmpty ? nil : FileTreeNode(url: url, isDirectory: true, children: children)
            }

            guard values.isRegularFile == true,
                  isMarkdownFile(url) else {
                return nil
            }

            return FileTreeNode(url: url, isDirectory: false)
        }

        return nodes.sorted { first, second in
            if first.isDirectory != second.isDirectory {
                return first.isDirectory && !second.isDirectory
            }

            return first.name.localizedStandardCompare(second.name) == .orderedAscending
        }
    }

    private static func isMarkdownFile(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return fileExtension == "md" || fileExtension == "markdown"
    }
}
