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
            .padding(24)
            .background(palette.editorSurface)
            .frame(maxWidth: DesignSystem.editorMaxWidth)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.documentCornerRadius)
                    .stroke(viewModel.isDocumentEdited ? Color.accentColor.opacity(0.32) : palette.subtleBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.documentCornerRadius))
            .shadow(color: palette.cardShadow, radius: 14, y: 7)
            .padding(.horizontal, 30)
            .padding(.vertical, 28)
        }
    }
}
