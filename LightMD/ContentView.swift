import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: MarkdownViewModel
    @StateObject private var appearance = ReaderAppearanceSettings()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.undoManager) private var undoManager
    @AppStorage("LightMDAppTheme") private var selectedThemeRaw = AppTheme.system.rawValue
    @State private var eventMonitor: Any?

    @StateObject private var workspaceViewModel: WorkspaceViewModel
    @StateObject private var folderTreeStore = FolderTreeStore()
    
    let windowRequest: DocumentWindowRequest?
    
    init(restoresLastSession: Bool = true, windowRequest: DocumentWindowRequest? = nil) {
        self.windowRequest = windowRequest
        _viewModel = StateObject(
            wrappedValue: MarkdownViewModel(
                windowRequest: windowRequest,
                restoresLastSession: restoresLastSession
            )
        )
        _workspaceViewModel = StateObject(wrappedValue: WorkspaceViewModel())
    }

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRaw) ?? .system
    }

    private var effectiveColorScheme: ColorScheme {
        selectedTheme.colorScheme ?? colorScheme
    }

    private var palette: DesignPalette {
        DesignSystem.palette(for: effectiveColorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(selectedThemeRaw: $selectedThemeRaw)

            if viewModel.document != nil, viewModel.mode == .reader {
                AnnotationBarView()
            }

            if !workspaceViewModel.tabs.isEmpty {
                FolderTabBarView()
            }
            
            content
        }
        .frame(minWidth: DesignSystem.windowMinWidth, minHeight: DesignSystem.windowMinHeight)
        .onAppear {
            viewModel.undoManager = undoManager
            setupEventMonitor()
            
            // Set default frame
            if let window = NSApplication.shared.windows.first {
                window.setContentSize(NSSize(width: DesignSystem.windowMinWidth, height: DesignSystem.windowMinHeight))
            }
        }
        .onChange(of: undoManager) { manager in
            viewModel.undoManager = manager
        }
        .background(palette.appBackground)
        .preferredColorScheme(selectedTheme.colorScheme)
        .environmentObject(viewModel)
        .environmentObject(appearance)
        .environmentObject(workspaceViewModel)
        .environmentObject(folderTreeStore)
        .focusedSceneValue(\.markdownViewModel, viewModel)
        .focusedSceneValue(\.workspaceViewModel, workspaceViewModel)
        .navigationTitle(viewModel.windowTitle)
        .alert("LightMD", isPresented: errorBinding) {
            Button("OK") {
                viewModel.clearError()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("NavigateBack"))) { _ in
            viewModel.navigateBack()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("NavigateForward"))) { _ in
            viewModel.navigateForward()
        }
        .onDisappear {
            if let eventMonitor {
                NSEvent.removeMonitor(eventMonitor)
            }
        }
        .onChange(of: workspaceViewModel.selectedTabID) { tabID in
            if let tabID = tabID, let tab = workspaceViewModel.tabs.first(where: { $0.id == tabID }) {
                viewModel.sync(with: tab, store: folderTreeStore)
            } else {
                // No tab selected, clear state
                viewModel.sync(with: WorkspaceTab(rootFolderURL: URL(fileURLWithPath: "/tmp")), store: folderTreeStore) // dummy
            }
        }
        .onAppear {
            viewModel.onDocumentLoaded = { url in
                workspaceViewModel.updateSelectedFile(url)
            }
            
            // If windowRequest has a rootFolderURL, ensure it's added to the workspace
            if let req = windowRequest, let rootURL = req.rootFolderURL {
                workspaceViewModel.addFolderTab(rootFolderURL: rootURL)
                workspaceViewModel.updateSelectedFile(req.fileURL)
            }
            
            if let tabID = workspaceViewModel.selectedTabID, let tab = workspaceViewModel.tabs.first(where: { $0.id == tabID }) {
                viewModel.sync(with: tab, store: folderTreeStore)
            }
        }
    }
    
    private func setupEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .otherMouseDown, .otherMouseUp, .swipe]) { event in
            // Handle cmd + [ and cmd + ]
            if event.type == .keyDown {
                if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command) {
                    if event.charactersIgnoringModifiers == "[" || event.keyCode == 33 {
                        viewModel.navigateBack()
                        return nil // Consume event
                    } else if event.charactersIgnoringModifiers == "]" || event.keyCode == 30 {
                        viewModel.navigateForward()
                        return nil
                    }
                }
            }
            
            // Handle swipe events (Magic Mouse / Trackpad)
            if event.type == .swipe {
                if event.deltaX > 0 {
                    viewModel.navigateBack()
                    return nil
                } else if event.deltaX < 0 {
                    viewModel.navigateForward()
                    return nil
                }
            }
            
            // Handle mouse back/forward buttons (button 3 is back, 4 is forward)
            // Handle mouse back/forward buttons
            if event.type == .otherMouseDown || event.type == .otherMouseUp {
                if event.buttonNumber == 3 {
                    if event.type == .otherMouseDown { viewModel.navigateBack() }
                    return nil
                } else if event.buttonNumber == 4 {
                    if event.type == .otherMouseDown { viewModel.navigateForward() }
                    return nil
                } else if event.buttonNumber == 5 {
                    if event.type == .otherMouseDown { viewModel.navigateForward() }
                    return nil
                }
            }
            
            return event
        }
    }

    private var content: some View {
        Group {
            if viewModel.document == nil {
                RecentFilesView()
            } else {
                workspace
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var workspace: some View {
        HStack(spacing: 0) {
            if viewModel.hasOpenFolder {
                FolderDocsSidebarView()
            }

            centerPane
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            OutlineSidebarView(navigationRequest: $viewModel.headingNavigationRequest)
        }
        .background(palette.appBackground)
    }

    @ViewBuilder
    private var centerPane: some View {
        if viewModel.mode == .reader {
            if let referencePane = viewModel.referencePane {
                HSplitView {
                    mainReader
                        .frame(minWidth: 420)

                    ReferencePaneView(pane: referencePane) {
                        viewModel.closeReferencePane()
                    }
                    .frame(minWidth: 320, idealWidth: 460)
                    .environment(\.openURL, OpenURLAction { url in
                        viewModel.handleLink(url, from: .reference) { request in
                            openWindow(value: request)
                        }

                        return .handled
                    })
                }
            } else {
                mainReader
            }
        } else {
            EditorView()
        }
    }

    private var mainReader: some View {
        ReaderView(
            annotationStore: viewModel.annotationStore,
            text: viewModel.markdownText,
            initialHeadingID: viewModel.activeHeadingID,
            navigationRequest: $viewModel.headingNavigationRequest,
            annotationApplyRequest: $viewModel.annotationApplyRequest
        )
        .id(viewModel.document?.url.standardizedFileURL.path ?? "reader")
        .environment(\.openURL, OpenURLAction { url in
            viewModel.handleLink(url, from: .main) { request in
                openWindow(value: request)
            }

            return .handled
        })
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearError()
                }
            }
        )
    }
}
