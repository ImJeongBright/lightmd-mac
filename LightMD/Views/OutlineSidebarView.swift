import SwiftUI

struct OutlineSidebarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @Binding var navigationRequest: HeadingNavigationRequest?
    
    @State private var backlinks: [URL] = []
    @State private var isBacklinksExpanded = true

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Outline Section ──────────────────────────────────────────
            outlineSection
            
            // ── Backlinks Section ────────────────────────────────────────
            if !backlinks.isEmpty {
                Divider()
                    .background(colors.divider)
                    .padding(.vertical, 8)
                
                backlinksSection
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(width: 220)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(colors.sidebarBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(colors.divider)
                .frame(width: 1)
        }
        .onAppear { refreshBacklinks() }
        .onChange(of: viewModel.document?.url) { _ in refreshBacklinks() }
        .onChange(of: viewModel.fileIndex.isReady) { _ in refreshBacklinks() }
    }
    
    // MARK: - Outline
    
    private var outlineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            outlineHeader
            
            if viewModel.outlineHeadings.isEmpty {
                Text("No headings")
                    .font(.caption)
                    .foregroundColor(colors.tertiaryText)
                    .padding(.horizontal, 4)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 3) {
                        ForEach(viewModel.outlineHeadings) { heading in
                            outlineRow(for: heading)
                        }
                    }
                }
            }
        }
    }

    private var outlineHeader: some View {
        HStack {
            Text("Outline")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colors.tertiaryText)
                .textCase(.uppercase)

            Spacer()

            if !viewModel.outlineHeadings.isEmpty {
                Text("\(viewModel.outlineHeadings.count)")
                    .font(.caption2)
                    .foregroundColor(colors.tertiaryText)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(colors.secondarySurface)
                    )
            }
        }
        .padding(.horizontal, 4)
    }

    private func outlineRow(for heading: MarkdownHeading) -> some View {
        HStack(spacing: 5) {
            Button {
                viewModel.selectHeading(heading)
                navigationRequest = HeadingNavigationRequest(headingID: heading.id)
            } label: {
                HStack(spacing: 7) {
                    Rectangle()
                        .fill(heading.id == viewModel.activeHeadingID ? colors.accent : Color.clear)
                        .frame(width: 2)

                    Text(heading.title)
                        .font(.system(size: fontSize(for: heading.level), weight: heading.level == 1 ? .medium : .regular))
                        .foregroundColor(heading.id == viewModel.activeHeadingID ? colors.primaryText : colors.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)
                }
                .padding(.leading, CGFloat(max(heading.level - 1, 0)) * 12)
                .padding(.vertical, 6)
                .padding(.trailing, 2)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(heading.id == viewModel.activeHeadingID ? colors.accentSoft : Color.clear)
                )
            }
            .buttonStyle(.plain)

            Button {
                viewModel.toggleFavoriteHeading(heading)
            } label: {
                AppIcon(
                    icon: viewModel.isFavoriteHeading(heading) ? .starFilled : .star,
                    size: 11
                )
                .foregroundColor(viewModel.isFavoriteHeading(heading) ? colors.accent : colors.tertiaryText)
                .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .help(viewModel.isFavoriteHeading(heading) ? "Remove favorite heading" : "Favorite heading")
        }
    }

    private func fontSize(for level: Int) -> CGFloat {
        switch level {
        case 1:
            return 13.5
        case 2:
            return 12.8
        default:
            return 12.2
        }
    }
    
    // MARK: - Backlinks
    
    private var backlinksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isBacklinksExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: isBacklinksExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(colors.tertiaryText)
                    
                    Text("Backlinks")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(colors.tertiaryText)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Text("\(backlinks.count)")
                        .font(.caption2)
                        .foregroundColor(colors.tertiaryText)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(colors.secondarySurface))
                }
                .padding(.horizontal, 4)
            }
            .buttonStyle(.plain)
            
            // List
            if isBacklinksExpanded {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(backlinks, id: \.self) { url in
                        BacklinkRow(url: url, colors: colors) {
                            viewModel.selectFile(url)
                        }
                    }
                }
            }
        }
    }
    
    private func refreshBacklinks() {
        guard let docURL = viewModel.document?.url else {
            backlinks = []
            return
        }
        backlinks = viewModel.fileIndex.backlinks(for: docURL)
    }
}

// MARK: - BacklinkRow

private struct BacklinkRow: View {
    let url: URL
    let colors: AppColors
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.turn.up.left")
                    .font(.system(size: 10))
                    .foregroundColor(colors.accent)
                
                Text(url.deletingPathExtension().lastPathComponent)
                    .font(.system(size: 12))
                    .foregroundColor(isHovered ? colors.primaryText : colors.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered ? colors.hoverBackground : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
