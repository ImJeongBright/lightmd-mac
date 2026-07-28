import SwiftUI

struct RecentFilesView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var workspaceViewModel: WorkspaceViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openWindow) private var openWindow

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        ZStack {
            colors.appBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("LightMD")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(colors.primaryText)

                        Text("Open a local Markdown file to start reading.")
                            .font(.callout)
                            .foregroundStyle(colors.secondaryText)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Button {
                            viewModel.openWithPanel()
                        } label: {
                            Label {
                                Text("Open")
                            } icon: {
                                AppIcon(icon: .folder, size: 16)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Button {
                            workspaceViewModel.openFolderWithPanel()
                        } label: {
                            Label {
                                Text("Folder")
                            } icon: {
                                AppIcon(icon: .workspace, size: 16)
                            }
                        }
                        .controlSize(.large)
                    }
                }

                if !viewModel.recentFiles.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Files")
                            .font(.headline)
                            .foregroundStyle(colors.primaryText)

                        VStack(spacing: 0) {
                            ForEach(viewModel.recentFiles, id: \.path) { url in
                                Button {
                                    viewModel.openRecent(url)
                                } label: {
                                    HStack(spacing: 11) {
                                        AppIcon(icon: .page, size: 18)
                                            .foregroundStyle(colors.secondaryText)
                                            .frame(width: 22)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(url.lastPathComponent)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(colors.primaryText)
                                                .lineLimit(1)

                                            Text(url.deletingLastPathComponent().path)
                                                .font(.caption)
                                                .foregroundStyle(colors.tertiaryText)
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
                                        .overlay(colors.divider)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.controlCornerRadius)
                                .fill(colors.secondarySurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.controlCornerRadius)
                                .stroke(colors.border, lineWidth: 1)
                        )
                    }
                }

                Spacer()
            }
            .frame(maxWidth: DesignSystem.welcomeMaxWidth, alignment: .leading)
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.documentCornerRadius)
                    .fill(colors.readerBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.documentCornerRadius)
                    .stroke(colors.border, lineWidth: 1)
            )
            .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
