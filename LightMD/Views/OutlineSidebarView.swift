import SwiftUI

struct OutlineSidebarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var navigationRequest: HeadingNavigationRequest?

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if viewModel.outlineHeadings.isEmpty {
                Text("No headings")
                    .font(.caption)
                    .foregroundStyle(palette.mutedText)
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
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(width: 250)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.thinMaterial)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(palette.border)
                .frame(width: 1)
        }
    }

    private var header: some View {
        HStack {
            Text("Outline")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.secondaryText)
                .textCase(.uppercase)

            Spacer()

            if !viewModel.outlineHeadings.isEmpty {
                Text("\(viewModel.outlineHeadings.count)")
                    .font(.caption2)
                    .foregroundStyle(palette.mutedText)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(palette.badgeBackground)
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
                        .fill(heading.id == viewModel.activeHeadingID ? Color.accentColor : Color.clear)
                        .frame(width: 2)

                    Text(heading.title)
                        .font(.system(size: fontSize(for: heading.level), weight: heading.level == 1 ? .medium : .regular))
                        .foregroundStyle(heading.id == viewModel.activeHeadingID ? palette.primaryText : palette.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)
                }
                .padding(.leading, CGFloat(max(heading.level - 1, 0)) * 12)
                .padding(.vertical, 6)
                .padding(.trailing, 2)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(heading.id == viewModel.activeHeadingID ? Color.accentColor.opacity(0.12) : Color.clear)
                )
            }
            .buttonStyle(.plain)

            Button {
                viewModel.toggleFavoriteHeading(heading)
            } label: {
                Image(systemName: viewModel.isFavoriteHeading(heading) ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundStyle(viewModel.isFavoriteHeading(heading) ? Color.accentColor : palette.mutedText)
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
}
