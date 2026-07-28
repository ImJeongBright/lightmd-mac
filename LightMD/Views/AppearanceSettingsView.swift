import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - System Font Helper

private enum SystemFontList {
    static let families: [String] = {
        let excluded: Set<String> = [
            "Symbol", "Zapf Dingbats", "Webdings", "Wingdings",
            "Marlett", "MT Extra", "LastResort"
        ]
        let all = NSFontManager.shared.availableFontFamilies
        let filtered = all.filter { name in
            !name.hasPrefix(".") &&
            !name.contains("ColorEmoji") &&
            !name.contains("Symbols Only") &&
            !excluded.contains(name)
        }
        return ["System"] + filtered
    }()
}

// MARK: - Main View

struct AppearanceSettingsView: View {
    @ObservedObject var settings: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var fontSearch = ""

    private var colors: AppColors {
        settings.resolvedColors(for: colorScheme)
    }
    private var selectedTheme: SceneTheme {
        SceneTheme.theme(for: settings.current.sceneThemeID)
    }
    private var filteredFonts: [String] {
        let all = SystemFontList.families
        if fontSearch.isEmpty { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(fontSearch) }
    }

    var body: some View {
        HSplitView {
            // Left controls panel
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    settingGroup("Theme") {
                        Picker("", selection: $settings.current.sceneThemeID) {
                            ForEach(SceneThemeID.allCases) { id in
                                let t = SceneTheme.theme(for: id)
                                HStack(spacing: 6) {
                                    Circle().fill(t.accent).frame(width: 8, height: 8)
                                    Text(t.displayName)
                                }.tag(id)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    settingGroup("Font") {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(colors.tertiaryText)
                                    .font(.system(size: 11))
                                TextField("Search fonts\u{2026}", text: $fontSearch)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 12))
                            }
                            .padding(.horizontal, 8).padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 6).fill(colors.hoverBackground))

                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(filteredFonts, id: \.self) { name in
                                        let isSelected = settings.current.fontFamilyName == name
                                        Button {
                                            settings.current.fontFamilyName = name
                                            fontSearch = ""
                                        } label: {
                                            HStack {
                                                Text(name == "System" ? "System Default" : name)
                                                    .font(name == "System" ? .system(size: 12) : .custom(name, size: 12))
                                                    .foregroundStyle(isSelected ? colors.accent : colors.primaryText)
                                                    .lineLimit(1)
                                                Spacer()
                                                if isSelected {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .foregroundStyle(colors.accent)
                                                }
                                            }
                                            .padding(.horizontal, 8).padding(.vertical, 5)
                                            .background(RoundedRectangle(cornerRadius: 4)
                                                .fill(isSelected ? colors.accentSoft : Color.clear))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(height: 150)
                            .background(RoundedRectangle(cornerRadius: 8).fill(colors.sidebarBackground))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.border, lineWidth: 0.5))
                        }
                    }

                    settingGroup("Size") {
                        HStack(spacing: 10) {
                            Button { settings.decreaseFontSize() } label: {
                                Image(systemName: "minus").frame(width: 28, height: 28)
                            }.buttonStyle(.bordered)
                            Text("\(settings.current.fontSizeBase) px")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(colors.primaryText)
                                .frame(width: 44)
                            Button { settings.increaseFontSize() } label: {
                                Image(systemName: "plus").frame(width: 28, height: 28)
                            }.buttonStyle(.bordered)
                        }
                    }

                    settingGroup("Line Spacing") {
                        Picker("", selection: $settings.current.lineSpacing) {
                            ForEach(LineSpacing.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }.pickerStyle(.segmented)
                    }

                    settingGroup("Width") {
                        Picker("", selection: $settings.current.contentWidth) {
                            ForEach(ContentWidth.allCases, id: \.self) { w in
                                Text(w.rawValue).tag(w)
                            }
                        }.pickerStyle(.segmented)
                    }

                    settingGroup("Background") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Button(settings.current.customBackgroundBookmark != nil ? "Change\u{2026}" : "Choose Image\u{2026}") {
                                    selectBg()
                                }.buttonStyle(.bordered)
                                if settings.current.customBackgroundBookmark != nil {
                                    Button("Remove") { settings.current.customBackgroundBookmark = nil }
                                        .buttonStyle(.plain).foregroundStyle(.red).font(.system(size: 11))
                                }
                            }
                            if settings.current.customBackgroundBookmark != nil {
                                sliderRow("Opacity", value: $settings.current.customBackgroundOpacity, range: 0...1)
                                sliderRow("Blur", value: $settings.current.customBackgroundBlur, range: 0...20)
                            }
                        }
                    }

                    Divider().overlay(colors.divider).padding(.vertical, 8)
                    Button("Reset to Defaults") { settings.reset() }
                        .buttonStyle(.plain).font(.system(size: 11)).foregroundStyle(colors.tertiaryText)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.bottom, 16)
                }
                .padding(.horizontal, 14).padding(.top, 14)
            }
            .frame(minWidth: 210, idealWidth: 230, maxWidth: 250)
            .background(colors.sidebarBackground)

            // Right preview panel
            ThemePreviewView(
                theme: selectedTheme,
                fontFamilyName: settings.current.fontFamilyName,
                fontSize: settings.current.fontSizeBase,
                lineSpacing: settings.current.lineSpacing
            )
            .frame(minWidth: 300)
        }
        .frame(minWidth: 540, minHeight: 460)
    }

    // MARK: - Helpers

    private func settingGroup<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(colors.tertiaryText)
                .tracking(0.8)
            content()
        }
        .padding(.vertical, 10)
    }

    private func sliderRow(_ label: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundStyle(colors.secondaryText).frame(width: 50, alignment: .leading)
            Slider(value: value, in: range)
        }
    }

    private func selectBg() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK, let url = panel.url,
           let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            settings.current.customBackgroundBookmark = data
        }
    }
}

// MARK: - Preview Panel

struct ThemePreviewView: View {
    let theme: SceneTheme
    let fontFamilyName: String
    let fontSize: Int
    let lineSpacing: LineSpacing

    private var bodyFont: Font {
        let size = CGFloat(fontSize)
        return fontFamilyName == "System" ? .system(size: size) : .custom(fontFamilyName, size: size)
    }

    var body: some View {
        ZStack {
            theme.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Simulated toolbar
                    HStack(spacing: 5) {
                        ForEach(0..<3, id: \.self) { _ in
                            Capsule().fill(theme.tertiaryText.opacity(0.35)).frame(width: 26, height: 7)
                        }
                        Spacer()
                        Capsule().fill(theme.accent.opacity(0.5)).frame(width: 38, height: 7)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(theme.sidebarBackground)

                    // Document
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Getting Started")
                            .font(fontFamilyName == "System"
                                  ? .system(size: CGFloat(fontSize) * 1.8, weight: .bold)
                                  : .custom(fontFamilyName, size: CGFloat(fontSize) * 1.8).bold())
                            .foregroundStyle(theme.primaryText)

                        Text("Overview")
                            .font(fontFamilyName == "System"
                                  ? .system(size: CGFloat(fontSize) * 1.25, weight: .semibold)
                                  : .custom(fontFamilyName, size: CGFloat(fontSize) * 1.25).weight(.semibold))
                            .foregroundStyle(theme.primaryText)

                        Text("This is sample body text to preview how your documents will look with the selected theme and typography. The quick brown fox jumps over the lazy dog.")
                            .font(bodyFont)
                            .foregroundStyle(theme.primaryText)
                            .lineSpacing(CGFloat(lineSpacing.cssValue - 1.0) * CGFloat(fontSize) * 0.45)

                        // Link
                        HStack(spacing: 0) {
                            Text("See also: ").font(bodyFont).foregroundStyle(theme.primaryText)
                            Text("Related document").font(bodyFont).foregroundStyle(theme.accent)
                        }

                        // Blockquote
                        HStack(spacing: 0) {
                            Rectangle().fill(theme.accent).frame(width: 3)
                            Text("A quoted passage from the original source material.")
                                .font(bodyFont).foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(theme.blockquoteBackground)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 3))

                        // Code
                        VStack(alignment: .leading) {
                            Text("let greeting = \"Hello, LightMD!\"\nprint(greeting)")
                                .font(.system(size: CGFloat(fontSize) * 0.88, design: .monospaced))
                                .foregroundStyle(theme.primaryText)
                                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(theme.codeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(theme.border, lineWidth: 0.5))

                        // List
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(["First item in list", "Second item with content", "Third item"], id: \.self) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Circle().fill(theme.secondaryText).frame(width: 4, height: 4)
                                        .padding(.top, CGFloat(fontSize) * 0.38)
                                    Text(item).font(bodyFont).foregroundStyle(theme.primaryText)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 22).padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.readerBackground)
                    .cornerRadius(4)
                    .padding(.horizontal, 10).padding(.bottom, 20).padding(.top, 8)
                }
            }
        }
    }
}
