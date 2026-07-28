import Foundation

@MainActor
final class MarkdownFileIndex: ObservableObject {
    @Published private(set) var isReady = false
    private var filesByNormalizedName: [String: [URL]] = [:]
    private var filesByRelativePath: [String: URL] = [:]
    
    // Backlink index: for each target file URL, which source file URLs link to it
    private var backlinksByTargetURL: [URL: Set<URL>] = [:]
    
    func rebuild(rootFolderURL: URL, markdownFiles: [FolderDocument]) {
        filesByNormalizedName.removeAll()
        filesByRelativePath.removeAll()
        backlinksByTargetURL.removeAll()
        
        for doc in markdownFiles {
            let url = doc.url.standardizedFileURL
            
            // 1. By relative path from root
            let rootPath = rootFolderURL.standardizedFileURL.path
            let filePath = url.path
            if filePath.hasPrefix(rootPath) {
                var relativePath = String(filePath.dropFirst(rootPath.count))
                if relativePath.hasPrefix("/") {
                    relativePath = String(relativePath.dropFirst())
                }
                filesByRelativePath[relativePath.lowercased()] = url
                
                // Also store without extension for easy match
                let withoutExt = (relativePath as NSString).deletingPathExtension
                filesByRelativePath[withoutExt.lowercased()] = url
            }
            
            // 2. By normalized name
            let name = url.deletingPathExtension().lastPathComponent.lowercased()
            filesByNormalizedName[name, default: []].append(url)
        }
        
        // 3. Build backlink index by scanning all files for WikiLinks
        buildBacklinkIndex(rootFolderURL: rootFolderURL, markdownFiles: markdownFiles)
        
        isReady = true
    }
    
    private func buildBacklinkIndex(rootFolderURL: URL, markdownFiles: [FolderDocument]) {
        let wikiLinkPattern = try? NSRegularExpression(pattern: "\\[\\[([^\\]]+)\\]\\]", options: [])
        
        for doc in markdownFiles {
            let sourceURL = doc.url.standardizedFileURL
            guard let content = try? String(contentsOf: sourceURL, encoding: .utf8) else { continue }
            
            let nsContent = content as NSString
            let range = NSRange(location: 0, length: nsContent.length)
            let matches = wikiLinkPattern?.matches(in: content, options: [], range: range) ?? []
            
            for match in matches {
                guard let captureRange = Range(match.range(at: 1), in: content) else { continue }
                var target = String(content[captureRange])
                
                // Handle aliases: [[Target|Alias]] -> use Target
                if let pipeIdx = target.firstIndex(of: "|") {
                    target = String(target[..<pipeIdx])
                }
                
                // Handle anchors: [[Target#Heading]] -> use Target
                if let hashIdx = target.firstIndex(of: "#") {
                    target = String(target[..<hashIdx])
                }
                
                target = target.trimmingCharacters(in: .whitespacesAndNewlines)
                if target.isEmpty { continue }
                
                // Resolve the target
                if let resolvedURL = resolveWikiLink(target: target, currentFileURL: sourceURL) {
                    backlinksByTargetURL[resolvedURL, default: []].insert(sourceURL)
                }
            }
        }
    }
    
    func clear() {
        filesByNormalizedName.removeAll()
        filesByRelativePath.removeAll()
        backlinksByTargetURL.removeAll()
        isReady = false
    }
    
    /// Returns all files that link to the given file URL via WikiLinks
    func backlinks(for fileURL: URL) -> [URL] {
        let standardized = fileURL.standardizedFileURL
        return Array(backlinksByTargetURL[standardized] ?? [])
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    
    func debugRelativePathCount() -> Int {
        filesByRelativePath.count
    }
    
    func debugNormalizedNameCount() -> Int {
        filesByNormalizedName.count
    }
    
    func resolveWikiLink(target: String, currentFileURL: URL?) -> URL? {
        let normalizedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let extensions = ["", ".md", ".markdown"]
        var searchTargets: [String] = []
        
        // Strip out leading ./
        var baseTarget = normalizedTarget
        if baseTarget.hasPrefix("./") {
            baseTarget = String(baseTarget.dropFirst(2))
        }
        
        for ext in extensions {
            if baseTarget.hasSuffix(ext) && !ext.isEmpty {
                searchTargets.append(baseTarget)
            } else {
                searchTargets.append(baseTarget + ext)
            }
        }
        
        // Remove duplicates
        searchTargets = Array(NSOrderedSet(array: searchTargets).compactMap { $0 as? String })
        
        // 1 & 2. Try relative to current file
        if let currentFileURL {
            let currentDir = currentFileURL.deletingLastPathComponent()
            for st in searchTargets {
                let candidate = currentDir.appendingPathComponent(st).standardizedFileURL
                if FileManager.default.fileExists(atPath: candidate.path) {
                    return candidate
                }
            }
        }
        
        // 3. Try relative to root (we can just check filesByRelativePath)
        for st in searchTargets {
            if let url = filesByRelativePath[st] {
                return url
            }
            if st.hasPrefix("/") {
                if let url = filesByRelativePath[String(st.dropFirst())] {
                    return url
                }
            }
        }
        
        // 4 & 5. Try stem matching in normalized names
        let nameMatch = (baseTarget as NSString).lastPathComponent
        let stem = (nameMatch as NSString).deletingPathExtension
        
        let candidates = filesByNormalizedName[stem] ?? []
        
        if candidates.isEmpty {
            return nil
        }
        
        if candidates.count == 1 {
            return candidates[0]
        }
        
        guard let currentFileURL else {
            return candidates[0]
        }
        
        return candidates.min(by: { a, b in
            let aDistance = pathDistance(from: currentFileURL, to: a)
            let bDistance = pathDistance(from: currentFileURL, to: b)
            return aDistance < bDistance
        }) ?? candidates[0]
    }
    
    private func pathDistance(from source: URL, to target: URL) -> Int {
        let sourceComps = source.standardizedFileURL.pathComponents
        let targetComps = target.standardizedFileURL.pathComponents
        
        var commonPrefixCount = 0
        for (s, t) in zip(sourceComps, targetComps) {
            if s == t {
                commonPrefixCount += 1
            } else {
                break
            }
        }
        
        // The fewer directories we have to go up/down, the "closer" it is.
        let upDirs = sourceComps.count - commonPrefixCount
        let downDirs = targetComps.count - commonPrefixCount
        return upDirs + downDirs
    }
}
