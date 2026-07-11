import SwiftUI

struct FolderDocsSidebarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var colorScheme
    @State private var expandedNodeIDs: Set<String> = []

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
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
        .background(palette.appBackground)
        .onAppear {
            expandRootNodes()
        }
        .onChange(of: viewModel.fileTree.map(\.id)) { _ in
            expandRootNodes()
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(palette.border)
                .frame(width: 1)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Docs")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.secondaryText)
                .textCase(.uppercase)

            Text(viewModel.folderName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(palette.primaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 4)
    }

    private func fileTreeNode(_ node: FileTreeNode, level: Int) -> AnyView {
        if node.isDirectory {
            return AnyView(VStack(alignment: .leading, spacing: 2) {
                Button {
                    toggleExpanded(node)
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: isExpanded(node) ? "chevron.down" : "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(palette.mutedText)
                            .frame(width: 11)

                        Image(systemName: isExpanded(node) ? "folder.fill" : "folder")
                            .font(.system(size: 12))
                            .foregroundStyle(palette.secondaryText)
                            .frame(width: 16)

                        Text(node.name)
                            .font(.system(size: 13, weight: level == 0 ? .medium : .regular))
                            .foregroundStyle(palette.primaryText)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer(minLength: 0)
                    }
                    .padding(.leading, CGFloat(level) * 12)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)

                if isExpanded(node) {
                    ForEach(node.children) { child in
                        fileTreeNode(child, level: level + 1)
                    }
                }
            })
        } else {
            return AnyView(Button {
                viewModel.selectFile(node.url)
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 12))
                        .foregroundStyle(isSelected(node) ? palette.primaryText : palette.mutedText)
                        .frame(width: 16)

                    Text(node.name)
                        .font(.system(size: 13))
                        .foregroundStyle(isSelected(node) ? palette.primaryText : palette.secondaryText)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer(minLength: 0)
                }
                .padding(.leading, CGFloat(level) * 12 + 18)
                .padding(.horizontal, 7)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected(node) ? palette.toolbarControlBackground : Color.clear)
                )
            }
            .buttonStyle(.plain)
            .contextMenu {
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
        expandedNodeIDs.formUnion(directoryIDs(in: viewModel.fileTree))
    }

    private func directoryIDs(in nodes: [FileTreeNode]) -> Set<String> {
        Set(nodes.flatMap { node -> [String] in
            guard node.isDirectory else {
                return []
            }

            return [node.id] + Array(directoryIDs(in: node.children))
        })
    }
}
