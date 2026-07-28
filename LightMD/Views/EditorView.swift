import SwiftUI

struct EditorView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var localText: String = ""

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    var body: some View {
        ZStack {
            colors.readerBackground
                .ignoresSafeArea()

            TextEditor(text: $localText)
            .onChange(of: localText) { newValue in
                if viewModel.markdownText != newValue {
                    viewModel.markdownText = newValue
                }
            }
            .onAppear {
                localText = viewModel.markdownText
            }
            .onChange(of: viewModel.markdownText) { newValue in
                if localText != newValue {
                    localText = newValue
                }
            }
            .font(MarkdownStyle.editorFont)
            .foregroundStyle(colors.primaryText)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, DesignSystem.readerHorizontalPadding)
            .padding(.vertical, DesignSystem.readerVerticalPadding)
            .frame(maxWidth: DesignSystem.editorMaxWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
