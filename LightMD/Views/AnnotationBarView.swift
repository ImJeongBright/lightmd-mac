import SwiftUI

struct AnnotationBarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShowingMemo = false

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }

    private var hasSelection: Bool {
        viewModel.hasTextSelection || viewModel.activeAnnotationID != nil
    }

    var body: some View {
        HStack(spacing: 4) {
            QuietIconButton(
                icon: .highlight,
                tooltip: "Highlight",
                isSelected: viewModel.selectedTextHasAnnotation(.highlight),
                isDisabled: !hasSelection
            ) {
                viewModel.toggleAnnotationForSelectedText(.highlight)
            }
            
            QuietIconButton(
                icon: .underline,
                tooltip: "Underline",
                isSelected: viewModel.selectedTextHasAnnotation(.underline),
                isDisabled: !hasSelection
            ) {
                viewModel.toggleAnnotationForSelectedText(.underline)
            }
            
            QuietIconButton(
                icon: .memo,
                tooltip: "Memo",
                isSelected: viewModel.selectedTextHasAnnotation(.memo),
                isDisabled: !hasSelection
            ) {
                isShowingMemo = true
            }
            .popover(isPresented: $isShowingMemo) {
                MemoPopoverView(
                    memo: viewModel.selectedBlockMemo,
                    onSave: { memo in
                        viewModel.setMemoForSelectedText(memo)
                        isShowingMemo = false
                    },
                    onRemove: {
                        viewModel.setMemoForSelectedText(nil)
                        isShowingMemo = false
                    }
                )
            }
            
            Divider().frame(height: 16)
            
            Menu {
                Button("Red") { viewModel.toggleAnnotationForSelectedText(.textColor, colorHex: "#FF3B30") }
                Button("Blue") { viewModel.toggleAnnotationForSelectedText(.textColor, colorHex: "#007AFF") }
                Button("Green") { viewModel.toggleAnnotationForSelectedText(.textColor, colorHex: "#34C759") }
                Button("Purple") { viewModel.toggleAnnotationForSelectedText(.textColor, colorHex: "#AF52DE") }
                Button("Orange") { viewModel.toggleAnnotationForSelectedText(.textColor, colorHex: "#FF9500") }
                
                Divider()
                
                Button(role: .destructive) { viewModel.clearColorForSelectedText() } label: {
                    Label("Clear Color", systemImage: "eraser")
                }
            } label: {
                AppIcon(icon: .textFormat, size: IconMetrics.toolbarSize)
                    .foregroundStyle(viewModel.selectedTextHasAnnotation(.textColor) ? colors.accent : colors.secondaryText)
                    .frame(width: IconMetrics.controlFrame, height: IconMetrics.controlFrame)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .disabled(!hasSelection)
            
            Divider().frame(height: 16)
            
            QuietIconButton(
                icon: .eraser,
                tooltip: "Clear Selection",
                isDisabled: !hasSelection
            ) {
                viewModel.clearAnnotationsForSelectedText()
            }
            
            QuietIconButton(
                icon: .close,
                tooltip: "Clear Active Annotation",
                isDisabled: viewModel.activeAnnotationID == nil
            ) {
                viewModel.clearActiveAnnotation()
            }
            
            Spacer(minLength: 12)
            
            if viewModel.activeAnnotationID != nil {
                Text("Annotation selected")
                    .font(.caption)
                    .foregroundStyle(colors.tertiaryText)
            } else if viewModel.hasTextSelection {
                Text("Text selected")
                    .font(.caption)
                    .foregroundStyle(colors.tertiaryText)
            } else {
                Text("No selection")
                    .font(.caption)
                    .foregroundStyle(colors.tertiaryText)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(colors.sidebarBackground)
        .overlay(alignment: .bottom) {
            Rectangle().fill(colors.divider).frame(height: 1)
        }
        .onChange(of: viewModel.activeAnnotationID) { newID in
            if newID != nil && viewModel.selectedTextHasAnnotation(.memo) {
                isShowingMemo = true
            } else {
                isShowingMemo = false
            }
        }
    }
}
