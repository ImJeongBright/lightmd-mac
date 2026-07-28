import SwiftUI
import AppKit

// MARK: - Appearance Window Controller (singleton panel)

@MainActor
final class AppearanceWindowController: NSObject {
    static let shared = AppearanceWindowController()
    private var window: NSPanel?

    func show(appearance: ReaderAppearanceSettings) {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = "Appearance"
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentMinSize = NSSize(width: 540, height: 420)
        panel.contentView = NSHostingView(
            rootView: AppearanceSettingsView(settings: appearance)
        )
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        self.window = panel
    }
}

// MARK: - Annotation Library Window Controller (singleton panel)

@MainActor
final class AnnotationLibraryWindowController: NSObject {
    static let shared = AnnotationLibraryWindowController()
    private var window: NSPanel?

    func show(viewModel: MarkdownViewModel, appearance: ReaderAppearanceSettings) {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 600),
            styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = "Annotations"
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentMinSize = NSSize(width: 400, height: 400)
        panel.contentView = NSHostingView(
            rootView: AnnotationLibraryView()
                .environmentObject(viewModel)
                .environmentObject(appearance)
        )
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        self.window = panel
    }
}

// MARK: - ToolbarView

struct ToolbarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var workspaceViewModel: WorkspaceViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedThemeRaw: String

    @AppStorage("isOutlineVisible") private var isOutlineVisible: Bool = true
    @AppStorage("isSidebarVisible") private var isSidebarVisible: Bool = true

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: 4) {
            // Left sidebar toggle — always visible
            QuietIconButton(
                icon: .sidebarLeft,
                tooltip: "Toggle File List",
                shortcut: "⌘⌥S",
                isSelected: isSidebarVisible
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isSidebarVisible.toggle()
                }
            }

            Divider()
                .frame(height: 16)
                .padding(.horizontal, 2)

            QuietIconButton(icon: .chevronLeft, tooltip: "Back", shortcut: "⌘[", isSelected: false, isDisabled: !viewModel.canNavigateBack) {
                viewModel.navigateBack()
            }
            QuietIconButton(icon: .chevronRight, tooltip: "Forward", shortcut: "⌘]", isSelected: false, isDisabled: !viewModel.canNavigateForward) {
                viewModel.navigateForward()
            }

            Spacer(minLength: 16)

            // Breadcrumb / Status
            HStack(spacing: 8) {
                if viewModel.document == nil {
                    Text(viewModel.currentFileName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                } else {
                    Text(viewModel.currentFileName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(1)

                    if viewModel.isDocumentEdited {
                        Text("Edited")
                            .font(.caption2)
                            .foregroundStyle(colors.secondaryText)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(colors.secondarySurface))
                    }
                    Text(viewModel.mode.statusTitle)
                        .font(.caption2)
                        .foregroundStyle(colors.secondaryText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(colors.hoverBackground))
                        
                    if viewModel.documentStatistics.wordCount > 0 {
                        Text("\(viewModel.documentStatistics.wordCount) words · \(viewModel.documentStatistics.readingTimeMinutes) min")
                            .font(.caption2)
                            .foregroundStyle(colors.tertiaryText)
                            .padding(.leading, 4)
                    }
                }
            }

            Spacer(minLength: 16)

            // Right controls
            if viewModel.document != nil {
                QuietIconButton(
                    icon: viewModel.mode == .reader ? .textFormat : .search,
                    text: viewModel.mode == .reader ? "Edit" : "Preview",
                    tooltip: "Toggle Mode"
                ) {
                    viewModel.toggleMode()
                }

                QuietIconButton(icon: .search, tooltip: "Search (⌘P)") {
                    /* placeholder for search */
                }
                
                QuietIconButton(icon: .bookmark, tooltip: "Annotation Library") {
                    AnnotationLibraryWindowController.shared.show(
                        viewModel: viewModel,
                        appearance: appearance
                    )
                }
            }

            // Outline toggle — always visible
            QuietIconButton(
                icon: .sidebarRight,
                tooltip: "Toggle Outline",
                shortcut: "⌘⌥O",
                isSelected: isOutlineVisible
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isOutlineVisible.toggle()
                }
            }

            // Appearance settings — direct button
            QuietIconButton(
                icon: .palette,
                tooltip: "Appearance Settings"
            ) {
                AppearanceWindowController.shared.show(appearance: appearance)
            }

            Divider()
                .frame(height: 16)
                .padding(.horizontal, 2)

            Menu {
                Button("Open Markdown File...") { viewModel.openWithPanel() }
                Button("Open Folder Workspace...") { workspaceViewModel.openFolderWithPanel() }
                Divider()
                if viewModel.canSave {
                    Button("Save") { viewModel.save() }
                }
                Divider()
                Picker("Theme", selection: $selectedThemeRaw) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.title).tag(theme.rawValue)
                    }
                }
                Button("Appearance Settings…") {
                    AppearanceWindowController.shared.show(appearance: appearance)
                }
            } label: {
                AppIcon(icon: .more, size: IconMetrics.toolbarSize)
                    .frame(width: IconMetrics.controlFrame, height: IconMetrics.controlFrame)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(height: 48)
        .background(colors.sidebarBackground)
        .overlay(alignment: .bottom) {
            Rectangle().fill(colors.divider).frame(height: 1)
        }
    }
}
