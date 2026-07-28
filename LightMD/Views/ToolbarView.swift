import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var workspaceViewModel: WorkspaceViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedThemeRaw: String
    @State private var isShowingAppearanceSettings = false

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: 4) {
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
                    // Document status
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
                
                QuietIconButton(icon: .search, tooltip: "Search") {
                    /* placeholder for search */
                }
            }
            
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
                Button("Appearance Settings") { isShowingAppearanceSettings = true }
            } label: {
                AppIcon(icon: .more, size: IconMetrics.toolbarSize)
                    .frame(width: IconMetrics.controlFrame, height: IconMetrics.controlFrame)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .popover(isPresented: $isShowingAppearanceSettings, arrowEdge: .bottom) {
                AppearanceSettingsView(settings: appearance)
            }
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
