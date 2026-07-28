import Foundation

enum PageIconType: String, Codable {
    case emoji
    case lineIcon
    case none
}

struct PageIcon: Codable, Equatable {
    var type: PageIconType
    var value: String
}

struct SidecarMetadata: Codable {
    var scrollOffset: Double?
    var filePath: String?
    var lastOpenedAt: Date?
    var lastReadHeadingID: String?
    var favoriteHeadingIDs: [String]
    var note: String
    var lastViewedAt: Date?
    var annotations: [MarkdownAnnotation]
    var pageIcon: PageIcon?

    init(
        filePath: String? = nil,
        lastOpenedAt: Date? = nil,
        lastReadHeadingID: String? = nil,
        favoriteHeadingIDs: [String] = [],
        note: String = "",
        lastViewedAt: Date? = nil,
        annotations: [MarkdownAnnotation] = [],
        pageIcon: PageIcon? = nil
    ) {
        self.filePath = filePath
        self.lastOpenedAt = lastOpenedAt
        self.lastReadHeadingID = lastReadHeadingID
        self.favoriteHeadingIDs = favoriteHeadingIDs
        self.note = note
        self.lastViewedAt = lastViewedAt
        self.annotations = annotations
        self.pageIcon = pageIcon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filePath = try container.decodeIfPresent(String.self, forKey: .filePath)
        lastOpenedAt = try container.decodeIfPresent(Date.self, forKey: .lastOpenedAt)
        lastReadHeadingID = try container.decodeIfPresent(String.self, forKey: .lastReadHeadingID)
        favoriteHeadingIDs = try container.decodeIfPresent([String].self, forKey: .favoriteHeadingIDs) ?? []
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        lastViewedAt = try container.decodeIfPresent(Date.self, forKey: .lastViewedAt)
        annotations = try container.decodeIfPresent([MarkdownAnnotation].self, forKey: .annotations) ?? []
        pageIcon = try container.decodeIfPresent(PageIcon.self, forKey: .pageIcon)
    }
}
