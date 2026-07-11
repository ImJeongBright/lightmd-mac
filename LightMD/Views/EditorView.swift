import SwiftUI

struct EditorView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var localText: String = ""

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
    }

    var body: some View {
        ZStack {
            palette.appBackground
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
            .foregroundStyle(palette.primaryText)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, DesignSystem.readerHorizontalPadding)
            .padding(.vertical, DesignSystem.readerVerticalPadding)
            .frame(maxWidth: DesignSystem.editorMaxWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(palette.editorSurface)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
