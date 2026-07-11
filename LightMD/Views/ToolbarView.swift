import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var workspaceViewModel: WorkspaceViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedThemeRaw: String
    @State private var isShowingAppearanceSettings = false

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.navigateBack()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
            }
            .disabled(!viewModel.canNavigateBack)
            .help("Back")

            Button {
                viewModel.navigateForward()
            } label: {
                Label("Forward", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
            }
            .disabled(!viewModel.canNavigateForward)
            .help("Forward")

            Divider()
                .frame(height: 24)

            Button {
                viewModel.openWithPanel()
            } label: {
                Label("Open", systemImage: "folder")
            }
            .help("Open Markdown file")

            Button {
                workspaceViewModel.openFolderWithPanel()
            } label: {
                Label("Folder", systemImage: "folder.badge.plus")
            }
            .help("Open Markdown folder")

            Divider()
                .frame(height: 24)

            Button {
                viewModel.toggleMode()
            } label: {
                Label(viewModel.mode.toggleTitle, systemImage: viewModel.mode.toggleIcon)
            }
            .disabled(viewModel.document == nil)
            .help("Toggle Preview/Edit")

            Button {
                viewModel.save()
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(!viewModel.canSave)
            .help("Save")

            Spacer(minLength: 16)

            fileStatus

            Spacer(minLength: 16)

            Menu {
                Picker("Theme", selection: $selectedThemeRaw) {
                    ForEach(AppTheme.allCases) { theme in
                        Label(theme.title, systemImage: theme.icon)
                            .tag(theme.rawValue)
                    }
                }
            } label: {
                Label("Theme", systemImage: "circle.lefthalf.filled")
            }
            .help("Theme")
            
            Button {
                isShowingAppearanceSettings = true
            } label: {
                Label("Appearance", systemImage: "textformat.size")
            }
            .help("Reader Appearance Settings")
            .popover(isPresented: $isShowingAppearanceSettings, arrowEdge: .bottom) {
                AppearanceSettingsView(settings: appearance)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(height: 58)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.border)
                .frame(height: 1)
        }
    }

    private var fileStatus: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.mode.statusIcon)
                .foregroundStyle(viewModel.document == nil ? palette.mutedText : Color.accentColor)
                .frame(width: 18)

            Text(viewModel.currentFileName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(viewModel.document == nil ? palette.secondaryText : palette.primaryText)
                .lineLimit(1)

            if viewModel.isDocumentEdited {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)

                    Text("Edited")
                        .font(.caption2)
                }
                .foregroundStyle(palette.secondaryText)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(palette.badgeBackground)
                )
            }

            if viewModel.document != nil {
                Text(viewModel.mode.statusTitle)
                    .font(.caption2)
                    .foregroundStyle(palette.secondaryText)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(palette.toolbarControlBackground)
                    )
            }
        }
        .frame(maxWidth: 360)
        .layoutPriority(1)
        .accessibilityElement(children: .combine)
    }
}
