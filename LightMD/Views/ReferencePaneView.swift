import SwiftUI

struct ReferencePaneView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var navigationRequest: HeadingNavigationRequest?

    let pane: ReaderPaneState
    let onClose: () -> Void

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ReaderView(
                annotationStore: viewModel.annotationStore,
                text: pane.markdownText,
                initialHeadingID: pane.activeHeadingID,
                navigationRequest: $navigationRequest,
                annotationApplyRequest: .constant(nil),
                allowsAnnotations: false,
                maxContentWidth: 560,
                outerHorizontalPadding: 16
            )
            .id("\(pane.currentFileURL.standardizedFileURL.path)-\(pane.activeHeadingID ?? "top")")
        }
        .background(colors.readerBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(colors.divider)
                .frame(width: 1)
        }
        .onAppear {
            requestInitialScroll()
        }
        .onChange(of: pane.activeHeadingID) { _ in
            requestInitialScroll()
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            AppIcon(icon: .splitPane, size: 14)
                .foregroundStyle(colors.accent)

            VStack(alignment: .leading, spacing: 1) {
                Text("Reference")
                    .font(.caption2)
                    .foregroundStyle(colors.tertiaryText)
                    .textCase(.uppercase)

                Text(pane.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                QuietIconButton(
                    icon: .chevronLeft,
                    tooltip: "Go Back (Reference)",
                    isDisabled: !viewModel.canNavigateReferenceBack,
                    size: 12
                ) {
                    viewModel.navigateReferenceBack()
                }

                QuietIconButton(
                    icon: .chevronRight,
                    tooltip: "Go Forward (Reference)",
                    isDisabled: !viewModel.canNavigateReferenceForward,
                    size: 12
                ) {
                    viewModel.navigateReferenceForward()
                }
            }

            Spacer(minLength: 8)

            QuietIconButton(
                icon: .close,
                tooltip: "Close Reference Pane",
                size: 12
            ) {
                onClose()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(colors.sidebarBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(colors.divider)
                .frame(height: 1)
        }
    }

    private func requestInitialScroll() {
        guard let headingID = pane.activeHeadingID else {
            return
        }

        navigationRequest = HeadingNavigationRequest(headingID: headingID)
    }
}
