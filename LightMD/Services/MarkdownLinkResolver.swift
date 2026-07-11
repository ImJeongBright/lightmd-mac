import Foundation

enum MarkdownLinkResolution: Equatable {
    case internalMarkdown(fileURL: URL, anchor: String?)
    case internalAnchor(anchor: String)
    case external(URL)
    case unsupported
    case missingFile(URL)
}

enum MarkdownLinkResolver {
    static func resolve(
        href: String,
        currentFileURL: URL,
        rootFolderURL: URL?
    ) -> MarkdownLinkResolution {
        if let url = URL(string: href) {
            return resolveLink(
                url,
                currentFileURL: currentFileURL,
                rootFolderURL: rootFolderURL
            )
        }

        let decodedHref = decoded(href)

        if decodedHref.hasPrefix("#") {
            return .internalAnchor(anchor: String(decodedHref.dropFirst()))
        }

        let parts = splitHref(decodedHref)

        if parts.path.isEmpty, let anchor = parts.anchor {
            return .internalAnchor(anchor: anchor)
        }

        guard isMarkdownPath(parts.path) else {
            return .unsupported
        }

        let currentDirectory = currentFileURL.deletingLastPathComponent()
        let candidates = candidateURLs(
            for: parts.path,
            currentDirectory: currentDirectory,
            rootFolderURL: rootFolderURL
        )

        if let existing = candidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }) {
            return .internalMarkdown(fileURL: existing.standardizedFileURL, anchor: parts.anchor)
        }

        return .missingFile(candidates.first ?? currentDirectory.appendingPathComponent(parts.path))
    }

    static func resolveLink(
        _ url: URL,
        currentFileURL: URL,
        rootFolderURL: URL?
    ) -> MarkdownLinkResolution {
        if let scheme = url.scheme?.lowercased(),
           ["http", "https", "mailto"].contains(scheme) {
            return .external(url)
        }

        if url.isFileURL {
            return resolveFileURL(url)
        }

        let href = decoded(url.absoluteString.isEmpty ? url.relativeString : url.absoluteString)

        if href.hasPrefix("#") {
            return .internalAnchor(anchor: String(href.dropFirst()))
        }

        guard !href.isEmpty else {
            return .unsupported
        }

        let parts = splitHref(href)

        if parts.path.isEmpty, let anchor = parts.anchor {
            return .internalAnchor(anchor: anchor)
        }

        guard isMarkdownPath(parts.path) else {
            return .unsupported
        }

        let currentDirectory = currentFileURL.deletingLastPathComponent()
        let candidates = candidateURLs(
            for: parts.path,
            currentDirectory: currentDirectory,
            rootFolderURL: rootFolderURL
        )

        if let existing = candidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }) {
            return .internalMarkdown(fileURL: existing.standardizedFileURL, anchor: parts.anchor)
        }

        return .missingFile(candidates.first ?? currentDirectory.appendingPathComponent(parts.path))
    }

    private static func resolveFileURL(_ url: URL) -> MarkdownLinkResolution {
        guard isMarkdownPath(url.path) else {
            return .external(url)
        }

        let standardizedURL = url.standardizedFileURL
        guard FileManager.default.fileExists(atPath: standardizedURL.path) else {
            return .missingFile(standardizedURL)
        }

        return .internalMarkdown(fileURL: standardizedURL, anchor: url.fragment)
    }

    private static func candidateURLs(
        for path: String,
        currentDirectory: URL,
        rootFolderURL: URL?
    ) -> [URL] {
        let decodedPath = decoded(path)
        var urls: [URL] = []

        if decodedPath.hasPrefix("/") {
            let absoluteURL = URL(fileURLWithPath: decodedPath).standardizedFileURL
            urls.append(absoluteURL)

            if let rootFolderURL {
                urls.append(rootFolderURL.appendingPathComponent(String(decodedPath.dropFirst())).standardizedFileURL)
            }
        } else {
            urls.append(currentDirectory.appendingPathComponent(decodedPath).standardizedFileURL)

            if let rootFolderURL {
                urls.append(rootFolderURL.appendingPathComponent(decodedPath).standardizedFileURL)
            }
        }

        return Array(NSOrderedSet(array: urls).compactMap { $0 as? URL })
    }

    private static func splitHref(_ href: String) -> (path: String, anchor: String?) {
        var path = href
        var anchor: String?

        if let hashIndex = path.firstIndex(of: "#") {
            let anchorStart = path.index(after: hashIndex)
            anchor = decoded(String(path[anchorStart...]))
            path = String(path[..<hashIndex])
        }

        if let queryIndex = path.firstIndex(of: "?") {
            path = String(path[..<queryIndex])
        }

        return (decoded(path), anchor?.isEmpty == true ? nil : anchor)
    }

    private static func isMarkdownPath(_ path: String) -> Bool {
        let lowercasedExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        return lowercasedExtension == "md" || lowercasedExtension == "markdown"
    }

    private static func decoded(_ value: String) -> String {
        value.removingPercentEncoding ?? value
    }
}
