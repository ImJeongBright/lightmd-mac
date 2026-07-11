import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
final class MarkdownViewModel: ObservableObject {
    struct AnnotationApplyRequest: Equatable {
        let requestID = UUID()
        let id: UUID
        let type: AnnotationType
        let selector: TextAnnotationSelector?
        let colorHex: String?
        let onSuccess: () -> Void
        
        static func == (lhs: AnnotationApplyRequest, rhs: AnnotationApplyRequest) -> Bool {
            lhs.requestID == rhs.requestID
        }
    }

    enum Mode {
        case reader
        case editor

        var toggleTitle: String {
            switch self {
            case .reader:
                return "Edit"
            case .editor:
                return "Preview"
            }
        }

        var toggleIcon: String {
            switch self {
            case .reader:
                return "pencil"
            case .editor:
                return "doc.text.magnifyingglass"
            }
        }

        var statusTitle: String {
            switch self {
            case .reader:
                return "Preview"
            case .editor:
                return "Edit"
            }
        }

        var statusIcon: String {
            switch self {
            case .reader:
                return "doc.text.magnifyingglass"
            case .editor:
                return "pencil.line"
            }
        }
    }

    @Published var document: MarkdownDocument?
    @Published var mode: Mode = .reader
    @Published private(set) var folderURL: URL?
    @Published private(set) var fileTree: [FileTreeNode] = []
    @Published private(set) var folderMarkdownFiles: [FolderDocument] = []
    @Published private(set) var outlineHeadings: [MarkdownHeading] = []
    @Published private(set) var activeHeadingID: String?
    @Published var headingNavigationRequest: HeadingNavigationRequest?
    @Published private(set) var referencePane: ReaderPaneState?
    @Published var selectedBlockID: String?
    @Published private(set) var recentFiles: [URL] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var navigationHistory = NavigationHistory()
    @Published private(set) var referenceNavigationHistory = NavigationHistory()
    @Published var currentSelectedText: String = ""
    @Published var currentSelectionSelector: TextAnnotationSelector?
    @Published var activeAnnotationID: UUID?
    @Published var annotationsNeedsReapply: UUID?
    @Published var hasTextSelection: Bool = false
    @Published var annotationApplyRequest: AnnotationApplyRequest?
    
    var fileIndex = MarkdownFileIndex()
    let annotationStore = AnnotationStore()
    var undoManager: UndoManager?

    private let recentFilesKey = "LightMDRecentFiles"
    private let lastOpenKindKey = "LightMDLastOpenKind"
    private let lastOpenedFileKey = "LightMDLastOpenedFile"
    private let lastOpenedFolderKey = "LightMDLastOpenedFolder"
    private let maxRecentFiles = 5
    private var sidecarMetadata = SidecarMetadata()
    private var securityScopedFolderURL: URL?
    private var isAccessingSecurityScopedFolder = false
    private var folderMonitor: FolderMonitor?
    
    // Timer for debouncing folder reloads
    private var folderReloadTimer: Timer?
    
    // Tab State Management
    private var historiesByTabID: [UUID: NavigationHistory] = [:]
    private var lastSyncedTabID: UUID?
    
    // Callback to WorkspaceViewModel to update selectedFileURL
    var onDocumentLoaded: ((URL) -> Void)?

    init(windowRequest: DocumentWindowRequest? = nil, restoresLastSession: Bool = true) {
        recentFiles = loadRecentFiles()

        if let windowRequest {
            loadWindowRequest(windowRequest)
        } else if restoresLastSession {
            restoreLastSession()
        }
    }

    var markdownText: String {
        get {
            document?.text ?? ""
        }
        set {
            guard var currentDocument = document else {
                return
            }

            currentDocument.text = newValue
            document = currentDocument
            refreshOutline()
        }
    }

    var canSave: Bool {
        document?.isDirty == true
    }

    var currentFileName: String {
        document?.title ?? "No Document"
    }

    var isDocumentEdited: Bool {
        document?.isDirty == true
    }

    var windowTitle: String {
        guard let document else {
            return "LightMD"
        }

        return document.isDirty ? "\(document.title) - Edited" : document.title
    }

    var hasOpenFolder: Bool {
        folderURL != nil
    }

    var hasReferencePane: Bool {
        referencePane != nil
    }

    var folderName: String {
        folderURL?.lastPathComponent ?? "Folder"
    }

    var canNavigateBack: Bool {
        navigationHistory.canGoBack
    }

    var canNavigateForward: Bool {
        navigationHistory.canGoForward
    }
    
    var canNavigateReferenceBack: Bool {
        referenceNavigationHistory.canGoBack
    }
    
    var canNavigateReferenceForward: Bool {
        referenceNavigationHistory.canGoForward
    }

    var hasSelectedBlock: Bool {
        selectedBlockID != nil
    }

    var selectedBlockMemo: String? {
        guard let activeAnnotationID else {
            return nil
        }

        return annotationStore.annotations
            .first { $0.id == activeAnnotationID && $0.type == .memo }?
            .memo
    }

    func openWithPanel() {
        guard confirmBeforeReplacingDocument() else {
            return
        }

        let panel = NSOpenPanel()
        panel.title = "Open Markdown File"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = markdownContentTypes

        if panel.runModal() == .OK, let url = panel.url {
            loadDocument(from: url, preserveFolderContext: false, recordsHistory: true)
        }
    }

    func sync(with tab: WorkspaceTab, store: FolderTreeStore) {
        lastSyncedTabID = tab.id
        
        // 1. Ensure tree is loaded
        store.loadTree(for: tab.rootFolderURL)
        
        // 2. Sync file tree and folder URL
        self.folderURL = tab.rootFolderURL
        self.fileTree = store.tree(for: tab.rootFolderURL) ?? []
        self.folderMarkdownFiles = store.files(for: tab.rootFolderURL) ?? []
        
        // 2. Sync file index
        if let idx = store.index(for: tab.rootFolderURL) {
            self.fileIndex = idx
        }
        
        // 3. Sync history
        if historiesByTabID[tab.id] == nil {
            historiesByTabID[tab.id] = NavigationHistory()
        }
        self.navigationHistory = historiesByTabID[tab.id]!
        
        // 4. Sync document
        if let url = tab.selectedFileURL {
            // Load without modifying history since it's just a tab switch
            if document?.url != url {
                loadDocument(from: url, preserveFolderContext: true, recordsHistory: false)
            }
        } else if let firstFile = self.folderMarkdownFiles.first?.url {
            // Auto-select first file if none selected
            loadDocument(from: firstFile, preserveFolderContext: true, recordsHistory: false)
        } else {
            // No file selected for this tab and no files available
            document = nil
            outlineHeadings = []
            activeHeadingID = nil
            selectedBlockID = nil
            sidecarMetadata = SidecarMetadata()
            annotationStore.load([])
        }
        
        // Setup folder monitor for current tab's folder
        setupFolderMonitor(for: tab.rootFolderURL, store: store)
    }


    func navigateReferenceBack() {
        if referenceNavigationHistory.canGoBack, let location = referenceNavigationHistory.goBack() {
            loadReferenceDocument(from: location.fileURL, requestedAnchor: location.headingID, recordsHistory: false)
        }
    }

    func navigateReferenceForward() {
        if referenceNavigationHistory.canGoForward, let location = referenceNavigationHistory.goForward() {
            loadReferenceDocument(from: location.fileURL, requestedAnchor: location.headingID, recordsHistory: false)
        }
    }

    func openRecent(_ url: URL) {
        guard confirmBeforeReplacingDocument() else {
            return
        }

        loadDocument(from: url, preserveFolderContext: false, recordsHistory: true)
    }

    func openFolderDocument(_ item: FolderDocument) {
        selectFile(item.url)
    }

    func selectFile(_ url: URL) {
        guard confirmBeforeReplacingDocument() else {
            return
        }

        loadDocument(from: url, preserveFolderContext: true, recordsHistory: true)
    }

    func windowRequest(for fileURL: URL, anchor: String? = nil) -> DocumentWindowRequest {
        DocumentWindowRequest(
            fileURL: fileURL,
            rootFolderURL: folderURLForWindowRequest(containing: fileURL),
            anchor: anchor
        )
    }

    func handleLink(
        _ url: URL,
        from sourcePane: ReaderPaneTarget,
        openNewWindow: (DocumentWindowRequest) -> Void
    ) {
        guard let sourceFileURL = fileURL(for: sourcePane) else {
            return
        }

        let resolution: MarkdownLinkResolution
        if url.scheme == "lightmd-wikilink" {
            resolution = resolveWikiLink(url, sourceFileURL: sourceFileURL)
        } else {
            resolution = MarkdownLinkResolver.resolveLink(
                url,
                currentFileURL: sourceFileURL,
                rootFolderURL: folderURL
            )
        }

        switch resolution {
        case let .internalMarkdown(fileURL, anchor):
            openResolvedMarkdownLink(
                fileURL: fileURL,
                anchor: anchor,
                sourcePane: sourcePane,
                openNewWindow: openNewWindow
            )

        case let .internalAnchor(anchor):
            openResolvedAnchorLink(
                anchor: anchor,
                sourcePane: sourcePane,
                openNewWindow: openNewWindow
            )

        case let .external(externalURL):
            NSWorkspace.shared.open(externalURL)

        case .unsupported:
            break

        case let .missingFile(missingURL):
            // Fallback for WikiLinks: missing files handled safely without modifying history
            if url.scheme == "lightmd-wikilink" {
                errorMessage = "WikiLink target not found: \(missingURL.lastPathComponent)"
            } else {
                errorMessage = "Linked file not found: \(missingURL.lastPathComponent)"
            }
        }
    }
    
    private func resolveWikiLink(_ url: URL, sourceFileURL: URL) -> MarkdownLinkResolution {
        var rawTarget = url.absoluteString
        if rawTarget.hasPrefix("lightmd-wikilink://") {
            rawTarget = String(rawTarget.dropFirst("lightmd-wikilink://".count))
        } else if rawTarget.hasPrefix("lightmd-wikilink:") {
            rawTarget = String(rawTarget.dropFirst("lightmd-wikilink:".count))
        }
        
        let anchor: String?
        if let hashIndex = rawTarget.firstIndex(of: "#") {
            anchor = String(rawTarget[rawTarget.index(after: hashIndex)...]).removingPercentEncoding
            rawTarget = String(rawTarget[..<hashIndex])
        } else {
            anchor = nil
        }
        
        let targetPath = rawTarget.removingPercentEncoding ?? rawTarget
        
        if targetPath.isEmpty, let anchor {
            return .internalAnchor(anchor: anchor)
        }
        
        if let resolvedURL = fileIndex.resolveWikiLink(target: targetPath, currentFileURL: sourceFileURL) {
            return .internalMarkdown(fileURL: resolvedURL, anchor: anchor)
        }
        
        errorMessage = "WikiLink '\(targetPath)' could not be resolved."
        
        // Target missing
        let missingFallback = folderURL?.appendingPathComponent(targetPath + ".md") ?? sourceFileURL.deletingLastPathComponent().appendingPathComponent(targetPath + ".md")
        return .missingFile(missingFallback)
    }

    func closeReferencePane() {
        referencePane = nil
    }

    func selectBlock(_ blockID: String) {
        guard mode == .reader else {
            return
        }

        selectedBlockID = blockID
    }

    func clearSelectedBlock() {
        selectedBlockID = nil
    }

    func navigateBack(allowInEditor: Bool = true) {
        guard allowInEditor || mode == .reader,
              navigationHistory.canGoBack,
              confirmBeforeReplacingDocument(),
              let location = navigationHistory.goBack() else {
            return
        }

        loadDocument(at: location, recordsHistory: false)
        objectWillChange.send()
    }

    func navigateForward(allowInEditor: Bool = true) {
        guard allowInEditor || mode == .reader,
              navigationHistory.canGoForward,
              confirmBeforeReplacingDocument(),
              let location = navigationHistory.goForward() else {
            return
        }

        loadDocument(at: location, recordsHistory: false)
        objectWillChange.send()
    }

    func toggleMode() {
        guard document != nil else {
            return
        }

        mode = mode == .reader ? .editor : .reader

        if mode == .editor {
            clearSelectedBlock()
        }
    }

    func save() {
        guard var currentDocument = document else {
            return
        }

        do {
            try FileLoader.saveMarkdown(currentDocument.text, to: currentDocument.url)
            currentDocument.originalText = currentDocument.text
            document = currentDocument
            refreshOutline()
            rememberRecentFile(currentDocument.url)
            saveSidecarMetadata()
        } catch {
            errorMessage = "Could not save \(currentDocument.title): \(error.localizedDescription)"
        }
    }

    func selectHeading(_ heading: MarkdownHeading) {
        activeHeadingID = heading.id
        navigationHistory.updateCurrent(headingID: heading.id)
        headingNavigationRequest = HeadingNavigationRequest(headingID: heading.id)
        sidecarMetadata.lastReadHeadingID = heading.id
        sidecarMetadata.lastViewedAt = Date()
        saveSidecarMetadata()
    }

    func toggleFavoriteHeading(_ heading: MarkdownHeading) {
        if sidecarMetadata.favoriteHeadingIDs.contains(heading.id) {
            sidecarMetadata.favoriteHeadingIDs.removeAll { $0 == heading.id }
        } else {
            sidecarMetadata.favoriteHeadingIDs.append(heading.id)
        }

        sidecarMetadata.lastViewedAt = Date()
        saveSidecarMetadata()
        objectWillChange.send()
    }

    func isFavoriteHeading(_ heading: MarkdownHeading) -> Bool {
        sidecarMetadata.favoriteHeadingIDs.contains(heading.id)
    }

    func selectedTextHasAnnotation(_ type: AnnotationType) -> Bool {
        if let activeAnnotationID {
            return annotationStore.hasAnnotation(id: activeAnnotationID, type: type)
        }
        return false
    }

    func toggleAnnotationForSelectedText(_ type: AnnotationType, colorHex: String? = nil) {
        let previousAnnotations = annotationStore.annotations
        
        if let activeAnnotationID {
            // If it's textColor and we provided a new colorHex, we should probably update it rather than just toggling it off.
            // But for simplicity, we just toggle it off if it exists.
            annotationStore.toggle(type, for: activeAnnotationID)
            
            // If we toggled it ON (it now exists), let's update the colorHex!
            if let colorHex {
                annotationStore.setColorHex(colorHex, for: activeAnnotationID)
            }
            
            registerUndo(previousAnnotations: previousAnnotations)
            persistAnnotations()
        } else if let selector = currentSelectionSelector {
            
            // Check if there are existing annotations of the same type that nearly match this selection
            let overlapping = annotationStore.allAnnotations.filter {
                $0.type == type &&
                abs($0.selector.startOffset - selector.startOffset) <= 20 &&
                abs($0.selector.endOffset - selector.endOffset) <= 20
            }
            
            if !overlapping.isEmpty {
                for existing in overlapping {
                    annotationStore.removeAnnotation(id: existing.id)
                }
                
                // If they are setting a text color explicitly, they probably want to apply the NEW color, not just remove it.
                // So if colorHex is provided, we still apply it.
                if let colorHex {
                    let newID = UUID()
                    annotationApplyRequest = AnnotationApplyRequest(
                        id: newID,
                        type: type,
                        selector: selector,
                        colorHex: colorHex,
                        onSuccess: { [weak self] in
                            self?.annotationStore.add(id: newID, type: type, selector: selector, fileURL: self?.document?.url, colorHex: colorHex)
                            self?.registerUndo(previousAnnotations: previousAnnotations)
                            self?.persistAnnotations()
                        }
                    )
                } else {
                    registerUndo(previousAnnotations: previousAnnotations)
                    persistAnnotations()
                    annotationsNeedsReapply = UUID()
                }
            } else {
                let newID = UUID()
                annotationApplyRequest = AnnotationApplyRequest(
                    id: newID,
                    type: type,
                    selector: selector,
                    colorHex: colorHex,
                    onSuccess: { [weak self] in
                        self?.annotationStore.add(id: newID, type: type, selector: selector, fileURL: self?.document?.url, colorHex: colorHex)
                        self?.registerUndo(previousAnnotations: previousAnnotations)
                        self?.persistAnnotations()
                    }
                )
            }
        }
    }

    func setMemoForSelectedText(_ memo: String?) {
        let previousAnnotations = annotationStore.annotations
        if let activeAnnotationID {
            annotationStore.setMemo(memo, for: activeAnnotationID)
            registerUndo(previousAnnotations: previousAnnotations)
            persistAnnotations()
        } else if let selector = currentSelectionSelector {
            // Find existing memo
            if let existing = annotationStore.allAnnotations.first(where: {
                $0.type == .memo &&
                abs($0.selector.startOffset - selector.startOffset) <= 20 &&
                abs($0.selector.endOffset - selector.endOffset) <= 20
            }) {
                annotationStore.setMemo(memo, for: existing.id)
                registerUndo(previousAnnotations: previousAnnotations)
                persistAnnotations()
            } else {
                guard let cleanedMemo = memo?.trimmingCharacters(in: .whitespacesAndNewlines), !cleanedMemo.isEmpty else { return }
                
                let newID = UUID()
                annotationApplyRequest = AnnotationApplyRequest(
                    id: newID,
                    type: .memo,
                    selector: selector,
                    colorHex: nil,
                    onSuccess: { [weak self] in
                        self?.annotationStore.add(id: newID, type: .memo, selector: selector, fileURL: self?.document?.url, memo: cleanedMemo)
                        self?.registerUndo(previousAnnotations: previousAnnotations)
                        self?.persistAnnotations()
                    }
                )
            }
        }
    }

    func clearActiveAnnotation() {
        let previousAnnotations = annotationStore.annotations
        if let activeAnnotationID {
            annotationStore.removeAnnotation(id: activeAnnotationID)
            self.activeAnnotationID = nil
            currentSelectionSelector = nil
            registerUndo(previousAnnotations: previousAnnotations)
            persistAnnotations()
            annotationsNeedsReapply = UUID()
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private var markdownContentTypes: [UTType] {
        [
            UTType(filenameExtension: "md") ?? .plainText,
            UTType(filenameExtension: "markdown") ?? .plainText
        ]
    }

    private func loadDocument(
        from url: URL,
        preserveFolderContext: Bool,
        recordsHistory: Bool,
        requestedAnchor: String? = nil
    ) {
        do {
            let text = try FileLoader.readMarkdown(from: url)
            document = MarkdownDocument(url: url, text: text)
            mode = .reader
            selectedBlockID = nil
            rememberRecentFile(url)
            refreshOutline()
            loadSidecarMetadata(for: url)

            if let requestedAnchor {
                applyAnchorIfPossible(requestedAnchor, headings: outlineHeadings)
            }

            recordLastOpen(fileURL: url, preserveFolderContext: preserveFolderContext)
            updateNavigationHistory(for: url, recordsHistory: recordsHistory)
            onDocumentLoaded?(url)

            if !preserveFolderContext {
                folderURL = nil
                fileTree = []
                folderMarkdownFiles = []
                fileIndex.clear()
                stopFolderAccess()
            }
        } catch {
            removeRecentFile(url)
            errorMessage = "Could not open \(url.lastPathComponent): \(error.localizedDescription)"
        }
    }

    private func loadDocument(at location: DocumentLocation, recordsHistory: Bool) {
        let preserveFolderContext = (folderURL != nil)

        loadDocument(
            from: location.fileURL,
            preserveFolderContext: preserveFolderContext,
            recordsHistory: recordsHistory,
            requestedAnchor: location.headingID
        )
    }


    private func setupFolderMonitor(for url: URL, store: FolderTreeStore? = nil) {
        folderMonitor?.stop()
        folderMonitor = FolderMonitor(url: url)
        folderMonitor?.folderDidChange = { [weak self, weak store] in
            // Debounce the reload
            self?.folderReloadTimer?.invalidate()
            self?.folderReloadTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                store?.refreshTree(for: url)
                if let tabID = self?.lastSyncedTabID {
                    // Update our view of the tree
                    self?.fileTree = store?.tree(for: url) ?? []
                    self?.folderMarkdownFiles = store?.files(for: url) ?? []
                    if let idx = store?.index(for: url) {
                        self?.fileIndex = idx
                    }
                }
            }
        }
        folderMonitor?.start()
    }

    private func reloadFolder() {
        // Obsolete, handled by FolderTreeStore now
    }

    private func confirmBeforeReplacingDocument() -> Bool {
        guard let currentDocument = document, currentDocument.isDirty else {
            return true
        }

        let alert = NSAlert()
        alert.messageText = "Save changes to \(currentDocument.title)?"
        alert.informativeText = "Your edits will be lost if you open another file without saving."
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Don't Save")
        alert.addButton(withTitle: "Cancel")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            save()
            return document?.isDirty == false
        case .alertSecondButtonReturn:
            return true
        default:
            return false
        }
    }

    private func loadRecentFiles() -> [URL] {
        let paths = UserDefaults.standard.stringArray(forKey: recentFilesKey) ?? []
        return paths
            .map { URL(fileURLWithPath: $0) }
            .filter { FileManager.default.fileExists(atPath: $0.path) }
            .prefix(maxRecentFiles)
            .map { $0 }
    }

    private func rememberRecentFile(_ url: URL) {
        let path = url.standardizedFileURL.path
        var paths = recentFiles
            .map { $0.standardizedFileURL.path }
            .filter { $0 != path }

        paths.insert(path, at: 0)
        paths = Array(paths.prefix(maxRecentFiles))
        UserDefaults.standard.set(paths, forKey: recentFilesKey)
        recentFiles = paths.map { URL(fileURLWithPath: $0) }
    }

    private func removeRecentFile(_ url: URL) {
        let path = url.standardizedFileURL.path
        let paths = recentFiles
            .map { $0.standardizedFileURL.path }
            .filter { $0 != path }

        UserDefaults.standard.set(paths, forKey: recentFilesKey)
        recentFiles = paths.map { URL(fileURLWithPath: $0) }
    }

    private func refreshOutline() {
        let headings = MarkdownRenderer.extractHeadings(markdownText)
        outlineHeadings = headings

        if let activeHeadingID, headings.contains(where: { $0.id == activeHeadingID }) {
            return
        }

        activeHeadingID = sidecarMetadata.lastReadHeadingID.flatMap { savedHeadingID in
            headings.contains(where: { $0.id == savedHeadingID }) ? savedHeadingID : nil
        } ?? headings.first?.id
    }

    private func loadSidecarMetadata(for url: URL) {
        sidecarMetadata = SidecarStore.load(for: url)
        sidecarMetadata.filePath = url.standardizedFileURL.path
        sidecarMetadata.lastOpenedAt = Date()
        sidecarMetadata.lastViewedAt = Date()
        annotationStore.load(sidecarMetadata.annotations)

        if let savedHeadingID = sidecarMetadata.lastReadHeadingID,
           outlineHeadings.contains(where: { $0.id == savedHeadingID }) {
            activeHeadingID = savedHeadingID
        } else {
            activeHeadingID = outlineHeadings.first?.id
            sidecarMetadata.lastReadHeadingID = activeHeadingID
        }

        saveSidecarMetadata()
    }

    private func updateNavigationHistory(for url: URL, recordsHistory: Bool) {
        let location = DocumentLocation(fileURL: url, headingID: activeHeadingID)

        if recordsHistory {
            navigationHistory.visit(location)
        } else {
            navigationHistory.setCurrent(location)
        }

        objectWillChange.send()
    }

    private func openResolvedMarkdownLink(
        fileURL: URL,
        anchor: String?,
        sourcePane: ReaderPaneTarget,
        openNewWindow: (DocumentWindowRequest) -> Void
    ) {
        switch linkDestination(from: sourcePane) {
        case .main:
            guard confirmBeforeReplacingDocument() else {
                return
            }

            loadDocument(
                from: fileURL,
                preserveFolderContext: shouldPreserveFolderContext(for: fileURL),
                recordsHistory: true,
                requestedAnchor: anchor
            )

        case .reference:
            loadReferenceDocument(from: fileURL, requestedAnchor: anchor)

        case .newWindow:
            openNewWindow(windowRequest(for: fileURL, anchor: anchor))
        }
    }

    private func openResolvedAnchorLink(
        anchor: String,
        sourcePane: ReaderPaneTarget,
        openNewWindow: (DocumentWindowRequest) -> Void
    ) {
        switch linkDestination(from: sourcePane) {
        case .main:
            navigateMainPane(to: anchor)

        case .reference:
            if sourcePane == .reference {
                navigateReferencePane(to: anchor)
            } else if let document {
                loadReferenceDocument(from: document.url, requestedAnchor: anchor)
            }

        case .newWindow:
            if let sourceFileURL = fileURL(for: sourcePane) {
                openNewWindow(windowRequest(for: sourceFileURL, anchor: anchor))
            }
        }
    }

    private enum LinkDestination {
        case main
        case reference
        case newWindow
    }

    private func linkDestination(from sourcePane: ReaderPaneTarget) -> LinkDestination {
        let flags = NSEvent.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if flags.contains(.command) {
            return .newWindow
        }

        if flags.contains(.option) {
            return .main
        }

        return .reference
    }

    private func fileURL(for pane: ReaderPaneTarget) -> URL? {
        switch pane {
        case .main:
            return document?.url
        case .reference:
            return referencePane?.currentFileURL
        }
    }

    private func navigateMainPane(to anchor: String) {
        guard let document else {
            return
        }

        guard let headingID = headingID(matching: anchor, in: outlineHeadings) else {
            errorMessage = "Heading not found: #\(anchor)"
            return
        }

        activeHeadingID = headingID
        navigationHistory.visit(DocumentLocation(fileURL: document.url, headingID: headingID))
        headingNavigationRequest = HeadingNavigationRequest(headingID: headingID)
        sidecarMetadata.lastReadHeadingID = headingID
        sidecarMetadata.lastViewedAt = Date()
        saveSidecarMetadata()
    }

    private func navigateReferencePane(to anchor: String) {
        guard var referencePane else {
            return
        }

        let headings = MarkdownRenderer.extractHeadings(referencePane.markdownText)
        guard let headingID = headingID(matching: anchor, in: headings) else {
            errorMessage = "Heading not found: #\(anchor)"
            return
        }

        referencePane.activeHeadingID = headingID
        self.referencePane = referencePane
        referenceNavigationHistory.visit(DocumentLocation(fileURL: referencePane.currentFileURL, headingID: headingID))
    }

    func openInRightPane(_ url: URL) {
        loadReferenceDocument(from: url, requestedAnchor: nil)
    }

    private func loadReferenceDocument(from url: URL, requestedAnchor: String?, recordsHistory: Bool = true) {
        do {
            let text = try FileLoader.readMarkdown(from: url)
            let headings = MarkdownRenderer.extractHeadings(text)
            let resolvedHeadingID = requestedAnchor.flatMap { anchor in
                headingID(matching: anchor, in: headings)
            }
            
            if recordsHistory {
                referenceNavigationHistory.visit(DocumentLocation(fileURL: url, headingID: resolvedHeadingID))
            }

            referencePane = ReaderPaneState(
                currentFileURL: url.standardizedFileURL,
                markdownText: text,
                activeHeadingID: resolvedHeadingID
            )
        } catch {
            errorMessage = "Could not open reference \(url.lastPathComponent): \(error.localizedDescription)"
        }
    }

    private func applyAnchorIfPossible(_ anchor: String, headings: [MarkdownHeading]) {
        guard let headingID = headingID(matching: anchor, in: headings) else {
            errorMessage = "Heading not found: #\(anchor)"
            return
        }

        activeHeadingID = headingID
        sidecarMetadata.lastReadHeadingID = headingID
        headingNavigationRequest = HeadingNavigationRequest(headingID: headingID)
    }

    private func headingID(matching anchor: String, in headings: [MarkdownHeading]) -> String? {
        let normalizedAnchor = normalizeAnchor(anchor)

        if headings.contains(where: { $0.id == normalizedAnchor }) {
            return normalizedAnchor
        }

        return headings.first { heading in
            MarkdownRenderer.anchorSlug(for: heading.title) == normalizedAnchor ||
                heading.id.hasSuffix("-\(normalizedAnchor)")
        }?.id
    }

    private func normalizeAnchor(_ anchor: String) -> String {
        let withoutHash = anchor.hasPrefix("#") ? String(anchor.dropFirst()) : anchor
        return (withoutHash.removingPercentEncoding ?? withoutHash)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func shouldPreserveFolderContext(for url: URL) -> Bool {
        folderMarkdownFiles.contains { item in
            item.url.standardizedFileURL.path == url.standardizedFileURL.path
        }
    }

    private func folderURLForWindowRequest(containing fileURL: URL) -> URL? {
        guard shouldPreserveFolderContext(for: fileURL) else {
            return nil
        }

        return folderURL
    }

    private func saveSidecarMetadata() {
        guard let document else {
            return
        }

        // Copy state before backgrounding
        sidecarMetadata.filePath = document.url.standardizedFileURL.path
        sidecarMetadata.annotations = annotationStore.allAnnotations
        let metaToSave = sidecarMetadata
        let urlToSave = document.url
        
        Task.detached(priority: .background) {
            do {
                try SidecarStore.save(metaToSave, for: urlToSave)
            } catch {
                await MainActor.run {
                    // It's a detached task, so we can't easily capture 'self' for errorMessage without risking retain cycles, 
                    // but we can just print to console if saving fails in background.
                    print("[MarkdownViewModel] Could not save reading state: \(error.localizedDescription)")
                }
            }
        }
    }

    func clearAnnotationsForSelectedText() {
        var didRemove = false
        
        if let activeAnnotationID {
            if let activeAnn = annotationStore.allAnnotations.first(where: { $0.id == activeAnnotationID }) {
                let overlapping = annotationStore.allAnnotations.filter {
                    $0.selector.startOffset <= activeAnn.selector.endOffset && $0.selector.endOffset >= activeAnn.selector.startOffset
                }
                for ann in overlapping {
                    annotationStore.removeAnnotation(id: ann.id)
                }
                didRemove = true
            }
        } else if let selector = currentSelectionSelector {
            let overlapping = annotationStore.annotations.filter {
                $0.selector.startOffset <= selector.endOffset && $0.selector.endOffset >= selector.startOffset
            }
            if !overlapping.isEmpty {
                for ann in overlapping {
                    annotationStore.removeAnnotation(id: ann.id)
                }
                didRemove = true
            }
        }
        
        if didRemove {
            activeAnnotationID = nil
            currentSelectionSelector = nil
            persistAnnotations()
            annotationsNeedsReapply = UUID()
        }
    }
    
    func clearColorForSelectedText() {
        var didRemove = false
        
        if let activeAnnotationID {
            if let activeAnn = annotationStore.allAnnotations.first(where: { $0.id == activeAnnotationID }) {
                let overlapping = annotationStore.allAnnotations.filter {
                    $0.type == .textColor && $0.selector.startOffset <= activeAnn.selector.endOffset && $0.selector.endOffset >= activeAnn.selector.startOffset
                }
                for ann in overlapping {
                    annotationStore.removeAnnotation(id: ann.id)
                }
                if !overlapping.isEmpty { didRemove = true }
            }
        } else if let selector = currentSelectionSelector {
            let overlapping = annotationStore.annotations.filter {
                $0.type == .textColor && $0.selector.startOffset <= selector.endOffset && $0.selector.endOffset >= selector.startOffset
            }
            if !overlapping.isEmpty {
                for ann in overlapping {
                    annotationStore.removeAnnotation(id: ann.id)
                }
                didRemove = true
            }
        }
        
        if didRemove {
            persistAnnotations()
            annotationsNeedsReapply = UUID()
        }
    }

    private func registerUndo(previousAnnotations: [MarkdownAnnotation]) {
        undoManager?.registerUndo(withTarget: self) { target in
            let current = target.annotationStore.annotations
            target.annotationStore.load(previousAnnotations)
            target.persistAnnotations()
            target.annotationsNeedsReapply = UUID()
            
            // Register redo
            target.registerUndo(previousAnnotations: current)
        }
    }

    private func persistAnnotations() {
        sidecarMetadata.annotations = annotationStore.allAnnotations
        sidecarMetadata.lastViewedAt = Date()
        saveSidecarMetadata()
        objectWillChange.send()
    }

    private func recordLastOpen(fileURL: URL, preserveFolderContext: Bool) {
        UserDefaults.standard.set(fileURL.standardizedFileURL.path, forKey: lastOpenedFileKey)

        if preserveFolderContext, let folderURL {
            UserDefaults.standard.set("folder", forKey: lastOpenKindKey)
            UserDefaults.standard.set(folderURL.standardizedFileURL.path, forKey: lastOpenedFolderKey)
        } else {
            UserDefaults.standard.set("file", forKey: lastOpenKindKey)
            UserDefaults.standard.removeObject(forKey: lastOpenedFolderKey)
        }
    }

    private func loadWindowRequest(_ request: DocumentWindowRequest) {
        // Folder setup is now handled by WorkspaceViewModel via ContentView.

        guard let fileURL = request.fileURL else {
            return
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            errorMessage = "Linked file not found: \(fileURL.lastPathComponent)"
            return
        }

        loadDocument(
            from: fileURL,
            preserveFolderContext: shouldPreserveFolderContext(for: fileURL),
            recordsHistory: false,
            requestedAnchor: request.anchor
        )
    }

    private func restoreLastSession() {
        let defaults = UserDefaults.standard
        let kind = defaults.string(forKey: lastOpenKindKey)
        let lastFileURL = defaults.string(forKey: lastOpenedFileKey).map { URL(fileURLWithPath: $0) }

        if kind == "folder" {
            // Folder restoration is handled by WorkspaceViewModel
            return
        }

        if let lastFileURL,
           FileManager.default.fileExists(atPath: lastFileURL.path) {
            loadDocument(from: lastFileURL, preserveFolderContext: false, recordsHistory: false)
        }
    }

    private func beginFolderAccess(for url: URL) {
        if securityScopedFolderURL?.standardizedFileURL.path == url.standardizedFileURL.path,
           isAccessingSecurityScopedFolder {
            return
        }

        stopFolderAccess()
        isAccessingSecurityScopedFolder = url.startAccessingSecurityScopedResource()
        securityScopedFolderURL = isAccessingSecurityScopedFolder ? url : nil
    }

    private func stopFolderAccess() {
        if isAccessingSecurityScopedFolder, let securityScopedFolderURL {
            securityScopedFolderURL.stopAccessingSecurityScopedResource()
        }

        securityScopedFolderURL = nil
        isAccessingSecurityScopedFolder = false
    }
}
