import Foundation

/// Represents a single annotation entry loaded from a sidecar file, enriched with file context
struct AnnotationLibraryEntry: Identifiable, Hashable {
    let id: UUID
    let annotation: MarkdownAnnotation
    let fileURL: URL
    let fileName: String
    
    var displayText: String {
        if annotation.type == .memo, let memo = annotation.memo, !memo.isEmpty {
            return memo
        }
        return annotation.selector.exact
    }
}
