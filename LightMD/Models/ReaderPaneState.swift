import Foundation

enum ReaderPaneTarget {
    case main
    case reference
}

struct ReaderPaneState: Identifiable, Equatable {
    let id = UUID()
    var currentFileURL: URL
    var markdownText: String
    var activeHeadingID: String?
    var isRendering = false

    var title: String {
        currentFileURL.lastPathComponent
    }
}

struct HeadingNavigationRequest: Equatable {
    let headingID: String
    let requestID = UUID()
}
