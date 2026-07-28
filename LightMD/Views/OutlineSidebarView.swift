import SwiftUI

struct OutlineSidebarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @Binding var navigationRequest: HeadingNavigationRequest?

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if viewModel.outlineHeadings.isEmpty {
                Text("No headings")
                    .font(.caption)
                    .foregroundStyle(colors.tertiaryText)
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
        .frame(width: 220)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(colors.sidebarBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(colors.divider)
                .frame(width: 1)
        }
    }

    private var header: some View {
        HStack {
            Text("Outline")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colors.tertiaryText)
                .textCase(.uppercase)

            Spacer()

            if !viewModel.outlineHeadings.isEmpty {
                Text("\(viewModel.outlineHeadings.count)")
                    .font(.caption2)
                    .foregroundStyle(colors.tertiaryText)
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
                        .foregroundStyle(heading.id == viewModel.activeHeadingID ? colors.primaryText : colors.secondaryText)
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
                .foregroundStyle(viewModel.isFavoriteHeading(heading) ? colors.accent : colors.tertiaryText)
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
