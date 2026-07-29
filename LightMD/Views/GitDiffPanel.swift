import SwiftUI
import AppKit

class GitDiffPanel {
    static let shared = GitDiffPanel()
    
    private var window: NSWindow?
    
    private init() {}
    
    func show(diff: String, fileName: String, appearance: ReaderAppearanceSettings, colorScheme: ColorScheme) {
        if window == nil {
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            win.titlebarAppearsTransparent = true
            win.titleVisibility = .hidden
            win.isMovableByWindowBackground = true
            win.isReleasedWhenClosed = false
            
            // Apply visual effect background
            let visualEffect = NSVisualEffectView()
            visualEffect.material = .popover
            visualEffect.state = .active
            visualEffect.blendingMode = .behindWindow
            win.contentView = visualEffect
            
            self.window = win
        }
        
        guard let win = window else { return }
        win.title = "Diff - \(fileName)"
        
        let rootView = DiffView(diffText: diff, fileName: fileName)
            .environmentObject(appearance)
            .preferredColorScheme(colorScheme)
        
        let hostingController = NSHostingController(rootView: rootView)
        hostingController.view.frame = win.contentView!.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Remove old subviews
        win.contentView?.subviews.forEach { $0.removeFromSuperview() }
        win.contentView?.addSubview(hostingController.view)
        
        win.center()
        win.makeKeyAndOrderFront(nil)
    }
    
    func hide() {
        window?.orderOut(nil)
    }
}

struct DiffView: View {
    let diffText: String
    let fileName: String
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Diff: \(fileName)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                
                Spacer()
                
                Button(action: {
                    GitDiffPanel.shared.hide()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(colors.tertiaryText)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(colors.sidebarBackground.opacity(0.8))
            
            Divider()
                .background(colors.divider)
            
            // Diff content
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    let lines = diffText.components(separatedBy: .newlines)
                    ForEach(0..<lines.count, id: \.self) { i in
                        diffLineView(lines[i])
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(colors.readerBackground)
        }
        .frame(width: 800, height: 600)
    }
    
    @ViewBuilder
    private func diffLineView(_ line: String) -> some View {
        let isAddition = line.hasPrefix("+") && !line.hasPrefix("+++")
        let isDeletion = line.hasPrefix("-") && !line.hasPrefix("---")
        let isHeader = line.hasPrefix("@@")
        
        let textColor: Color = {
            if isAddition { return .green }
            if isDeletion { return .red }
            if isHeader { return .cyan }
            if line.hasPrefix("diff") || line.hasPrefix("index") || line.hasPrefix("---") || line.hasPrefix("+++") {
                return colors.tertiaryText
            }
            return colors.primaryText
        }()
        
        let bgColor: Color = {
            if isAddition { return Color.green.opacity(0.15) }
            if isDeletion { return Color.red.opacity(0.15) }
            if isHeader { return Color.cyan.opacity(0.1) }
            return .clear
        }()
        
        Text(line)
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bgColor)
            .cornerRadius(2)
    }
}
