import SwiftUI

struct FolderDocsSidebarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var colorScheme
    @State private var expandedNodeIDs: Set<String> = []
    @State private var hoveredNodeID: String?

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(viewModel.fileTree) { node in
                        fileTreeNode(node, level: 0)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(width: 220)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(colors.sidebarBackground)
        .onAppear {
            expandRootNodes()
        }
        .onChange(of: viewModel.fileTree.map(\.id)) { _ in
            expandRootNodes()
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(colors.divider)
                .frame(width: 1)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Docs")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colors.tertiaryText)
                .textCase(.uppercase)

            Text(viewModel.folderName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(colors.primaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 4)
    }

    private func fileTreeNode(_ node: FileTreeNode, level: Int) -> AnyView {
        if node.isDirectory {
            let isDirHovered = hoveredNodeID == node.id
            return AnyView(VStack(alignment: .leading, spacing: 2) {
                Button {
                    toggleExpanded(node)
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: isExpanded(node) ? "chevron.down" : "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(colors.tertiaryText)
                            .frame(width: 11)

                        Text(node.name)
                            .font(.system(size: 13, weight: level == 0 ? .medium : .regular))
                            .foregroundStyle(colors.primaryText)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer(minLength: 0)
                        
                        if node.gitStatus != .normal {
                            Circle()
                                .fill(Color.orange.opacity(0.8))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.leading, CGFloat(level) * 12)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: IconMetrics.cornerRadius)
                            .fill(isDirHovered ? colors.hoverBackground : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    hoveredNodeID = hovering ? node.id : nil
                }

                if isExpanded(node) {
                    ForEach(node.children) { child in
                        fileTreeNode(child, level: level + 1)
                    }
                }
            })
        } else {
            let isFileSelected = isSelected(node)
            let isFileHovered = hoveredNodeID == node.id
            return AnyView(Button {
                viewModel.selectFile(node.url)
            } label: {
                HStack(spacing: 7) {
                    AppIcon(icon: .page, size: 12)
                        .foregroundStyle(isFileSelected ? colors.accent : colors.tertiaryText)
                        .frame(width: 16)

                    Text(node.name)
                        .font(.system(size: 13))
                        .foregroundStyle(isFileSelected ? colors.primaryText : colors.secondaryText)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer(minLength: 0)
                    
                    gitStatusBadge(for: node.gitStatus)
                }
                .padding(.leading, CGFloat(level) * 12 + 18)
                .padding(.horizontal, 7)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: IconMetrics.cornerRadius)
                        .fill(isFileSelected ? colors.accentSoft : (isFileHovered ? colors.hoverBackground : Color.clear))
                )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                hoveredNodeID = hovering ? node.id : nil
            }
            .contextMenu {
                if node.gitStatus == .modified || node.gitStatus == .added || node.gitStatus == .untracked {
                    Button("Diff 보기") {
                        if let diff = GitStatusService.getDiff(for: node.url, in: viewModel.folderURL ?? node.url.deletingLastPathComponent()) {
                            GitDiffPanel.shared.show(
                                diff: diff,
                                fileName: node.name,
                                appearance: appearance,
                                colorScheme: colorScheme
                            )
                        }
                    }
                    Divider()
                }
                
                Button("오른쪽 창에서 열기") {
                    viewModel.openInRightPane(node.url)
                }
                Button("Open in New Window") {
                    openWindow(value: viewModel.windowRequest(for: node.url))
                }
            })
        }
    }

    private func isSelected(_ node: FileTreeNode) -> Bool {
        viewModel.document?.url.standardizedFileURL.path == node.url.standardizedFileURL.path
    }

    private func isExpanded(_ node: FileTreeNode) -> Bool {
        expandedNodeIDs.contains(node.id)
    }

    private func toggleExpanded(_ node: FileTreeNode) {
        if expandedNodeIDs.contains(node.id) {
            expandedNodeIDs.remove(node.id)
        } else {
            expandedNodeIDs.insert(node.id)
        }
    }

    private func expandRootNodes() {
        // Only expand root-level directories, not recursively all subdirectories
        for node in viewModel.fileTree where node.isDirectory {
            expandedNodeIDs.insert(node.id)
        }
    }
    
    @ViewBuilder
    private func gitStatusBadge(for status: GitStatus) -> some View {
        if status != .normal {
            Text(status.rawValue)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(colorForGitStatus(status))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(colorForGitStatus(status).opacity(0.15))
                .cornerRadius(4)
        }
    }
    
    private func colorForGitStatus(_ status: GitStatus) -> Color {
        switch status {
        case .added, .untracked: return Color.green.opacity(0.8)
        case .modified: return Color.orange.opacity(0.8)
        case .deleted: return Color.red.opacity(0.8)
        default: return colors.secondaryText
        }
    }
}
