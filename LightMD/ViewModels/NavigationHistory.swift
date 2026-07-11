import Foundation

@MainActor
final class NavigationHistory: ObservableObject {
    @Published var current: DocumentLocation?
    @Published private(set) var backStack: [DocumentLocation] = []
    @Published private(set) var forwardStack: [DocumentLocation] = []

    var canGoBack: Bool {
        !backStack.isEmpty
    }

    var canGoForward: Bool {
        !forwardStack.isEmpty
    }

    func visit(_ location: DocumentLocation) {
        if let current {
            guard !current.isSameLocation(as: location) else {
                return
            }

            backStack.append(current)
        }

        current = location
        forwardStack = []
    }

    func setCurrent(_ location: DocumentLocation?) {
        current = location
    }

    func updateCurrent(headingID: String?, scrollOffset: Double? = nil) {
        guard var current else {
            return
        }

        current.headingID = headingID
        current.scrollOffset = scrollOffset
        self.current = current
    }

    func goBack() -> DocumentLocation? {
        guard let target = backStack.popLast() else {
            return nil
        }

        if let current {
            forwardStack.append(current)
        }

        current = target
        return target
    }

    func goForward() -> DocumentLocation? {
        guard let target = forwardStack.popLast() else {
            return nil
        }

        if let current {
            backStack.append(current)
        }

        current = target
        return target
    }

    func clear() {
        current = nil
        backStack = []
        forwardStack = []
    }
}
