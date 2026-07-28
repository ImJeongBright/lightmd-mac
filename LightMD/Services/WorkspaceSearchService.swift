import Foundation

final class WorkspaceSearchService {
    
    // Quick Open
    func searchFiles(query: String, in rootFolderURL: URL, files: [URL]) -> [QuickOpenItem] {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let allItems = files.map { fileURL -> QuickOpenItem in
            let relativePath = relativePath(for: fileURL, relativeTo: rootFolderURL)
            let title = fileURL.deletingPathExtension().lastPathComponent
            return QuickOpenItem(
                fileURL: fileURL,
                title: title,
                relativePath: relativePath
            )
        }
        
        if cleanedQuery.isEmpty {
            return allItems.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        }
        
        // Simple fuzzy search or substring match
        return allItems.filter { item in
            item.title.lowercased().contains(cleanedQuery) ||
            item.relativePath.lowercased().contains(cleanedQuery)
        }.sorted { (a, b) in
            // Exact matches or startsWith first, then alphabetical
            let aStarts = a.title.lowercased().hasPrefix(cleanedQuery)
            let bStarts = b.title.lowercased().hasPrefix(cleanedQuery)
            if aStarts && !bStarts { return true }
            if !aStarts && bStarts { return false }
            return a.title.localizedStandardCompare(b.title) == .orderedAscending
        }
    }
    
    // Full Text Search
    func searchContent(query: String, in rootFolderURL: URL, files: [URL], maxResults: Int = 100) async -> [WorkspaceSearchResult] {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedQuery.isEmpty {
            return []
        }
        
        var results: [WorkspaceSearchResult] = []
        let searchTarget = cleanedQuery.lowercased()
        
        for fileURL in files {
            // Check cancellation
            if Task.isCancelled { break }
            
            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
                continue
            }
            
            let lines = content.components(separatedBy: .newlines)
            
            for (lineIndex, line) in lines.enumerated() {
                let lowerLine = line.lowercased()
                if let range = lowerLine.range(of: searchTarget) {
                    let startOffset = lowerLine.distance(from: lowerLine.startIndex, to: range.lowerBound)
                    let endOffset = lowerLine.distance(from: lowerLine.startIndex, to: range.upperBound)
                    
                    let title = fileURL.deletingPathExtension().lastPathComponent
                    let relative = relativePath(for: fileURL, relativeTo: rootFolderURL)
                    
                    // Keep snippet short
                    let snippet = String(line.prefix(200)) // limit length
                    
                    results.append(WorkspaceSearchResult(
                        fileURL: fileURL,
                        title: title,
                        relativePath: relative,
                        lineNumber: lineIndex + 1,
                        snippet: snippet,
                        matchStartOffset: startOffset,
                        matchEndOffset: min(endOffset, 200)
                    ))
                    
                    if results.count >= maxResults {
                        return results
                    }
                }
            }
        }
        
        return results
    }
    
    private func relativePath(for fileURL: URL, relativeTo rootFolderURL: URL) -> String {
        let rootPath = rootFolderURL.standardizedFileURL.path
        let filePath = fileURL.standardizedFileURL.path
        if filePath.hasPrefix(rootPath) {
            let relative = filePath.dropFirst(rootPath.count)
            if relative.hasPrefix("/") {
                return String(relative.dropFirst())
            }
            return String(relative)
        }
        return fileURL.lastPathComponent
    }
}
