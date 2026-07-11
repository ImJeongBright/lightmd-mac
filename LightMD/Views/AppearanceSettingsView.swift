import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var settings: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    
    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Appearance")
                .font(.headline)
                .foregroundStyle(palette.primaryText)
            
            // Font Size
            VStack(alignment: .leading, spacing: 8) {
                Text("Font Size")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                
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
            VStack(alignment: .leading, spacing: 8) {
                Text("Font Family")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                
                Picker("", selection: $settings.current.fontFamily) {
                    ForEach(FontFamily.allCases, id: \.self) { font in
                        Text(font.rawValue).tag(font)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Line Spacing
            VStack(alignment: .leading, spacing: 8) {
                Text("Line Spacing")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                
                Picker("", selection: $settings.current.lineSpacing) {
                    ForEach(LineSpacing.allCases, id: \.self) { spacing in
                        Text(spacing.rawValue).tag(spacing)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Content Width
            VStack(alignment: .leading, spacing: 8) {
                Text("Width")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                
                Picker("", selection: $settings.current.contentWidth) {
                    ForEach(ContentWidth.allCases, id: \.self) { width in
                        Text(width.rawValue).tag(width)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Theme
            VStack(alignment: .leading, spacing: 8) {
                Text("Theme")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                
                Picker("", selection: $settings.current.documentTheme) {
                    ForEach(DocumentTheme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
            
            Button("Reset to Defaults") {
                settings.reset()
            }
            .buttonStyle(.link)
            .font(.caption)
            .foregroundStyle(Color.red)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(width: 280)
        .background(palette.appBackground)
    }
}
