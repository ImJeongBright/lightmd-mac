import SwiftUI

struct RecentFilesView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var workspaceViewModel: WorkspaceViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openWindow) private var openWindow

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
    }

    var body: some View {
        ZStack {
            palette.appBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("LightMD")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(palette.primaryText)

                        Text("Open a local Markdown file to start reading.")
                            .font(.callout)
                            .foregroundStyle(palette.secondaryText)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Button {
                            viewModel.openWithPanel()
                        } label: {
                            Label("Open", systemImage: "folder")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Button {
                            workspaceViewModel.openFolderWithPanel()
                        } label: {
                            Label("Folder", systemImage: "folder.badge.plus")
                        }
                        .controlSize(.large)
                    }
                }

                if !viewModel.recentFiles.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Files")
                            .font(.headline)
                            .foregroundStyle(palette.primaryText)

                        VStack(spacing: 0) {
                            ForEach(viewModel.recentFiles, id: \.path) { url in
                                Button {
                                    viewModel.openRecent(url)
                                } label: {
                                    HStack(spacing: 11) {
                                        Image(systemName: "doc.text")
                                            .foregroundStyle(palette.secondaryText)
                                            .frame(width: 22)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(url.lastPathComponent)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(palette.primaryText)
                                                .lineLimit(1)

                                            Text(url.deletingLastPathComponent().path)
                                                .font(.caption)
                                                .foregroundStyle(palette.mutedText)
                                                .lineLimit(1)
                                        }

                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("오른쪽 창에서 열기") {
                                        viewModel.openInRightPane(url)
                                    }
                                    Button("Open in New Window") {
                                        openWindow(value: viewModel.windowRequest(for: url))
                                    }
                                }

                                if url != viewModel.recentFiles.last {
                                    Divider()
                                        .overlay(palette.subtleBorder)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.controlCornerRadius)
                                .fill(palette.codeBackground.opacity(0.62))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.controlCornerRadius)
                                .stroke(palette.subtleBorder, lineWidth: 1)
                        )
                    }
                }

                Spacer()
            }
            .frame(maxWidth: DesignSystem.welcomeMaxWidth, alignment: .leading)
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.documentCornerRadius)
                    .fill(palette.documentSurface)
                    .shadow(color: palette.cardShadow, radius: 16, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.documentCornerRadius)
                    .stroke(palette.subtleBorder, lineWidth: 1)
            )
            .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
