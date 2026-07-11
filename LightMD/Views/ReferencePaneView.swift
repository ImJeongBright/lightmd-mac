import SwiftUI

struct ReferencePaneView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var navigationRequest: HeadingNavigationRequest?

    let pane: ReaderPaneState
    let onClose: () -> Void

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
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
        .background(palette.appBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(palette.border)
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
            Image(systemName: "sidebar.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 1) {
                Text("Reference")
                    .font(.caption2)
                    .foregroundStyle(palette.mutedText)
                    .textCase(.uppercase)

                Text(pane.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.primaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 8)

            HStack(spacing: 12) {
                Button {
                    viewModel.navigateReferenceBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.canNavigateReferenceBack ? palette.primaryText : palette.mutedText)
                .disabled(!viewModel.canNavigateReferenceBack)
                .help("Go Back (Reference)")

                Button {
                    viewModel.navigateReferenceForward()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.canNavigateReferenceForward ? palette.primaryText : palette.mutedText)
                .disabled(!viewModel.canNavigateReferenceForward)
                .help("Go Forward (Reference)")
            }

            Spacer(minLength: 8)

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .foregroundStyle(palette.secondaryText)
            .help("Close Reference Pane")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.thinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.border)
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
