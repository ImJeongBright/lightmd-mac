import SwiftUI

struct ReaderView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var annotationStore: AnnotationStore

    let text: String
    let initialHeadingID: String?
    @Binding var navigationRequest: HeadingNavigationRequest?
    @Binding var annotationApplyRequest: MarkdownViewModel.AnnotationApplyRequest?
    var allowsAnnotations = true
    var maxContentWidth = DesignSystem.readerMaxWidth
    var outerHorizontalPadding: CGFloat = 30

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        ZStack {
            colors.readerBackground
                .ignoresSafeArea()

            HTMLReaderView(
                annotationStore: annotationStore,
                text: text,
                baseURL: viewModel.document?.url.deletingLastPathComponent(),
                annotationApplyRequest: $annotationApplyRequest
            )
            .frame(maxWidth: maxContentWidth, alignment: .leading)
            .padding(.horizontal, DesignSystem.readerHorizontalPadding)
            .padding(.vertical, DesignSystem.readerVerticalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
