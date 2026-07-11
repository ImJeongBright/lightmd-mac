import Foundation

@MainActor
final class MarkdownFileIndex: ObservableObject {
    @Published private(set) var isReady = false
    private var filesByNormalizedName: [String: [URL]] = [:]
    private var filesByRelativePath: [String: URL] = [:]
    
    func rebuild(rootFolderURL: URL, markdownFiles: [FolderDocument]) {
        filesByNormalizedName.removeAll()
        filesByRelativePath.removeAll()
        
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
        
        isReady = true
    }
    
    func clear() {
        filesByNormalizedName.removeAll()
        filesByRelativePath.removeAll()
        isReady = false
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
