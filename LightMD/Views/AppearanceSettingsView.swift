import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var settings: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: AppColors {
        settings.resolvedColors(for: colorScheme)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Appearance")
                    .font(.headline)
                    .foregroundStyle(colors.primaryText)
                
                // Theme
                settingSection("Theme") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 8)], spacing: 8) {
                        ForEach(ReaderTheme.allCases) { theme in
                            themeButton(theme)
                        }
                    }
                }
                
                // Accent Color
                settingSection("Accent Color") {
                    HStack(spacing: 10) {
                        ForEach(AccentPreset.allCases) { preset in
                            accentButton(preset)
                        }
                    }
                }

                // Highlight Color
                settingSection("Highlight Color") {
                    HStack(spacing: 10) {
                        ForEach(HighlightPreset.allCases) { preset in
                            highlightButton(preset)
                        }
                    }
                }

                // Text Color
                settingSection("Text Color") {
                    Picker("", selection: $settings.current.textColorPreset) {
                        ForEach(TextColorPreset.allCases) { preset in
                            Text(preset.label).tag(preset)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Font Size
                settingSection("Font Size") {
                    HStack {
                        Button(action: { settings.decreaseFontSize() }) {
                            Image(systemName: "textformat.size.smaller")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Text("\(settings.current.fontSizeBase)px")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .frame(width: 40, alignment: .center)
                        
                        Button(action: { settings.increaseFontSize() }) {
                            Image(systemName: "textformat.size.larger")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Font Family
                settingSection("Font") {
                    Picker("", selection: $settings.current.fontFamily) {
                        ForEach(FontFamily.allCases, id: \.self) { font in
                            Text(font.rawValue).tag(font)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Line Spacing
                settingSection("Line Spacing") {
                    Picker("", selection: $settings.current.lineSpacing) {
                        ForEach(LineSpacing.allCases, id: \.self) { spacing in
                            Text(spacing.rawValue).tag(spacing)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Content Width
                settingSection("Width") {
                    Picker("", selection: $settings.current.contentWidth) {
                        ForEach(ContentWidth.allCases, id: \.self) { width in
                            Text(width.rawValue).tag(width)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Divider()
                    .overlay(colors.divider)
                
                Button("Reset to Defaults") {
                    settings.reset()
                }
                .buttonStyle(.link)
                .font(.caption)
                .foregroundStyle(Color.red)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
        }
        .frame(width: 280)
        .frame(maxHeight: 520)
        .background(colors.sidebarBackground)
    }

    // MARK: - Components

    @ViewBuilder
    private func settingSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(colors.secondaryText)
            content()
        }
    }

    private func themeButton(_ theme: ReaderTheme) -> some View {
        let isSelected = settings.current.readerTheme == theme
        return Button {
            settings.current.readerTheme = theme
        } label: {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(themePreviewColor(theme))
                    .frame(height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? colors.accent : colors.border, lineWidth: isSelected ? 2 : 1)
                    )
                Text(theme.label)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? colors.primaryText : colors.secondaryText)
            }
        }
        .buttonStyle(.plain)
    }

    private func accentButton(_ preset: AccentPreset) -> some View {
        let isSelected = settings.current.accentPreset == preset
        return Button {
            settings.current.accentPreset = preset
        } label: {
            Circle()
                .fill(preset.color)
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? preset.color : Color.clear, lineWidth: 3)
                        .padding(-2)
                )
        }
        .buttonStyle(.plain)
        .help(preset.label)
    }

    private func highlightButton(_ preset: HighlightPreset) -> some View {
        let isSelected = settings.current.highlightPreset == preset
        return Button {
            settings.current.highlightPreset = preset
        } label: {
            Circle()
                .fill(highlightPreviewColor(preset))
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .stroke(isSelected ? colors.primaryText : colors.border, lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
        .help(preset.label)
    }

    // MARK: - Helpers

    private func themePreviewColor(_ theme: ReaderTheme) -> Color {
        switch theme {
        case .clean:    return Color(hex: 0xFCFBF8)
        case .paper:    return Color(hex: 0xF5EFE2)
        case .mist:     return Color(hex: 0xF6F9FC)
        case .sage:     return Color(hex: 0xF6FAF6)
        case .dark:     return Color(hex: 0x1D1F24)
        case .midnight: return Color(hex: 0x141620)
        }
    }

    private func highlightPreviewColor(_ preset: HighlightPreset) -> Color {
        switch preset {
        case .yellow: return Color(red: 1.00, green: 0.89, blue: 0.47)
        case .green:  return Color(red: 0.60, green: 0.83, blue: 0.60)
        case .blue:   return Color(red: 0.58, green: 0.77, blue: 0.94)
        case .pink:   return Color(red: 0.94, green: 0.66, blue: 0.75)
        case .purple: return Color(red: 0.77, green: 0.66, blue: 0.91)
        case .orange: return Color(red: 0.97, green: 0.78, blue: 0.55)
        }
    }
}
