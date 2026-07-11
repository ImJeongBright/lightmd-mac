import Foundation

@MainActor
final class AnnotationStore: ObservableObject {
    @Published private(set) var annotations: [MarkdownAnnotation] = []

    var allAnnotations: [MarkdownAnnotation] {
        annotations
    }

    func load(_ annotations: [MarkdownAnnotation]) {
        self.annotations = annotations
    }

    func hasAnnotation(id: UUID, type: AnnotationType) -> Bool {
        annotations.contains { $0.id == id && $0.type == type }
    }

    func add(id: UUID = UUID(), type: AnnotationType, selector: TextAnnotationSelector, fileURL: URL?, memo: String? = nil, colorHex: String? = nil) {
        let newAnnotation = MarkdownAnnotation(
            id: id,
            selector: selector,
            type: type,
            memo: memo,
            colorHex: colorHex,
            createdAt: Date(),
            updatedAt: Date()
        )
        annotations.append(newAnnotation)
    }

    func toggle(_ type: AnnotationType, for id: UUID) {
        if let index = annotations.firstIndex(where: { $0.id == id && $0.type == type }) {
            annotations.remove(at: index)
        } else if let existing = annotations.first(where: { $0.id == id }) {
            // Note: Since each type is a separate annotation now, but they share the same selector conceptually, 
            // the user requested we can just add a new one with the same selector.
            annotations.append(MarkdownAnnotation(selector: existing.selector, type: type, colorHex: existing.colorHex))
        }
    }

    func setMemo(_ memo: String?, for id: UUID) {
        let cleanedMemo = memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date()

        if let index = annotations.firstIndex(where: { $0.id == id && $0.type == .memo }) {
            if let cleanedMemo, !cleanedMemo.isEmpty {
                annotations[index].memo = cleanedMemo
                annotations[index].updatedAt = now
            } else {
                annotations.remove(at: index)
            }
            return
        }

        guard let cleanedMemo, !cleanedMemo.isEmpty, let existing = annotations.first(where: { $0.id == id }) else {
            return
        }

        annotations.append(MarkdownAnnotation(selector: existing.selector, type: .memo, memo: cleanedMemo))
    }
    
    func setColorHex(_ colorHex: String?, for id: UUID) {
        if let index = annotations.firstIndex(where: { $0.id == id }) {
            annotations[index].colorHex = colorHex
            annotations[index].updatedAt = Date()
        }
    }

    func removeAnnotation(id: UUID) {
        annotations.removeAll { $0.id == id }
    }
    
    func clearAll() {
        annotations.removeAll()
    }
}

