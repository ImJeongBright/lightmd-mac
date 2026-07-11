import Foundation

enum SidecarStore {
    static func sidecarURL(for markdownURL: URL) -> URL {
        let directory = markdownURL.deletingLastPathComponent()
        let hiddenFilename = "." + markdownURL.lastPathComponent + ".lightmd.json"
        return directory.appendingPathComponent(hiddenFilename)
    }

    static func load(for markdownURL: URL) -> SidecarMetadata {
        let url = sidecarURL(for: markdownURL)

        guard let data = try? Data(contentsOf: url),
              let metadata = try? JSONDecoder().decode(SidecarMetadata.self, from: data) else {
            return SidecarMetadata()
        }

        return metadata
    }

    static func save(_ metadata: SidecarMetadata, for markdownURL: URL) throws {
        let url = sidecarURL(for: markdownURL)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(metadata)
        try data.write(to: url, options: .atomic)
    }
}
