import SwiftUI

struct MemoPopoverView: View {
    @State private var text: String

    let onSave: (String) -> Void
    let onRemove: () -> Void

    init(memo: String?, onSave: @escaping (String) -> Void, onRemove: @escaping () -> Void) {
        _text = State(initialValue: memo ?? "")
        self.onSave = onSave
        self.onRemove = onRemove
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Memo")
                .font(.headline)

            TextEditor(text: $text)
                .font(.system(size: 13))
                .frame(width: 280, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                )

            HStack {
                Button("Remove") {
                    onRemove()
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()

                Button("Save") {
                    onSave(text)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(14)
    }
}
