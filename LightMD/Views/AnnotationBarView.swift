import SwiftUI

struct AnnotationBarView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShowingMemo = false

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
    }

    private var hasSelection: Bool {
        viewModel.hasTextSelection || viewModel.activeAnnotationID != nil
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
            Label("Annotations", systemImage: "text.badge.checkmark")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(palette.secondaryText)

            Divider()
                .frame(height: 20)

            annotationButton(
                title: "Highlight",
                systemImage: viewModel.selectedTextHasAnnotation(.highlight) ? "highlighter" : "highlighter",
                isActive: viewModel.selectedTextHasAnnotation(.highlight)
            ) {
                viewModel.toggleAnnotationForSelectedText(.highlight)
            }

            annotationButton(
                title: "Underline",
                systemImage: "underline",
                isActive: viewModel.selectedTextHasAnnotation(.underline)
            ) {
                viewModel.toggleAnnotationForSelectedText(.underline)
            }

            Button {
                isShowingMemo = true
            } label: {
                Label("Memo", systemImage: viewModel.selectedTextHasAnnotation(.memo) ? "note.text" : "note.text")
            }
            .disabled(!hasSelection)
            .buttonStyle(.bordered)
            .foregroundStyle(viewModel.selectedTextHasAnnotation(.memo) ? Color.accentColor : palette.secondaryText)
            .help("Memo")
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
            
            Divider()
                .frame(height: 20)

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
                Label("Color", systemImage: "character")
            }
            .disabled(!hasSelection)
            .buttonStyle(.bordered)
            .foregroundStyle(viewModel.selectedTextHasAnnotation(.textColor) ? Color.accentColor : palette.secondaryText)
            .help("Text Color")

            Divider()
                .frame(height: 20)

            Button(role: .destructive) {
                viewModel.clearAnnotationsForSelectedText()
            } label: {
                Label("Clear", systemImage: "eraser")
            }
            .disabled(!hasSelection)
            .buttonStyle(.bordered)
            .foregroundStyle(hasSelection ? .red : palette.secondaryText)
            .help("Clear all overlapping annotations")

            Button {
                viewModel.clearActiveAnnotation()
            } label: {
                Label("Clear", systemImage: "xmark.circle")
            }
            .disabled(viewModel.activeAnnotationID == nil)
            .buttonStyle(.bordered)
            .foregroundStyle(palette.secondaryText)
            .help("Clear annotations")

            Spacer(minLength: 12)

            if viewModel.activeAnnotationID != nil {
                Text("Annotation selected")
                    .font(.caption)
                    .foregroundStyle(palette.mutedText)
            } else if viewModel.hasTextSelection {
                Text("Text selected")
                    .font(.caption)
                    .foregroundStyle(palette.mutedText)
            } else {
                Text("No selection")
                    .font(.caption)
                    .foregroundStyle(palette.mutedText)
            }
        }
        .controlSize(.small)
        .padding(.vertical, 7)
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(.bar)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.border)
                .frame(height: 1)
        }
        .onChange(of: viewModel.activeAnnotationID) { newID in
            if newID != nil && viewModel.selectedTextHasAnnotation(.memo) {
                isShowingMemo = true
            } else {
                isShowingMemo = false
            }
        }
    }

    private func annotationButton(
        title: String,
        systemImage: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
        }
        .disabled(!hasSelection)
        .buttonStyle(.bordered)
        .foregroundStyle(isActive ? Color.accentColor : palette.secondaryText)
        .help(title)
    }
}
