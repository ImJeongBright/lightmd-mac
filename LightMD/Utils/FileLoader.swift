import Foundation

enum FileLoader {
    static func readMarkdown(from url: URL) throws -> String {
        let data = try Data(contentsOf: url)

        if let text = String(data: data, encoding: .utf8) {
            return text
        }

        if let text = String(data: data, encoding: .unicode) {
            return text
        }

        throw CocoaError(.fileReadInapplicableStringEncoding)
    }

    static func saveMarkdown(_ text: String, to url: URL) throws {
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    static func markdownFiles(in folderURL: URL) throws -> [URL] {
        let urls = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        return urls
            .filter { url in
                let fileExtension = url.pathExtension.lowercased()
                guard fileExtension == "md" || fileExtension == "markdown" else {
                    return false
                }

                let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
                return values?.isRegularFile == true
            }
            .sorted { first, second in
                first.lastPathComponent.localizedStandardCompare(second.lastPathComponent) == .orderedAscending
            }
    }
}
