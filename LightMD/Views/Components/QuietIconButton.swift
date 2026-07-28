import SwiftUI

struct QuietIconButton: View {
    let icon: LightMDIcon
    var text: String? = nil
    var tooltip: String? = nil
    var shortcut: String? = nil
    var isSelected: Bool = false
    var isDisabled: Bool = false
    var size: CGFloat = IconMetrics.toolbarSize
    var color: Color? = nil
    let action: () -> Void
    
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false
    
    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                AppIcon(
                    icon: icon,
                    size: size,
                    weight: isSelected ? .regular : .light
                )
                
                if let text = text {
                    Text(text)
                        .font(.system(size: 13))
                }
            }
            .foregroundStyle(
                isDisabled ? colors.tertiaryText :
                (isSelected ? colors.accent : (isHovered ? colors.primaryText : (color ?? colors.secondaryText)))
            )
            .padding(.horizontal, text != nil ? 10 : (IconMetrics.controlFrame - size) / 2)
            .frame(minWidth: text != nil ? 0 : IconMetrics.controlFrame, minHeight: IconMetrics.controlFrame)
            .background(
                RoundedRectangle(cornerRadius: IconMetrics.cornerRadius)
                    .fill(isSelected ? colors.accentSoft : (isHovered && !isDisabled ? colors.hoverBackground : Color.clear))
            )
            .animation(.easeInOut(duration: 0.12), value: isHovered)
            .animation(.easeInOut(duration: 0.12), value: isSelected)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onHover { hovering in
            isHovered = hovering
        }
        .help(helpString)
    }
    
    private var helpString: String {
        var parts: [String] = []
        if let tooltip = tooltip {
            parts.append(tooltip)
        }
        if let shortcut = shortcut {
            parts.append(shortcut)
        }
        return parts.joined(separator: " ")
    }
}
