import SwiftUI
import WebKit

/// A floating NSPanel that shows a preview of a WikiLink target document
final class WikiLinkPreviewPanel: NSPanel {
    static let shared = WikiLinkPreviewPanel()
    
    private var hostingView: NSHostingView<AnyView>?
    
    private init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 280),
            styleMask: [.nonactivatingPanel, .titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        isReleasedWhenClosed = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        level = .popUpMenu
        isMovableByWindowBackground = true
        backgroundColor = .clear
        hasShadow = true
        isOpaque = false
    }
    
    func show(content: String, title: String, at point: CGPoint, appearance: ReaderAppearanceSettings, colorScheme: ColorScheme) {
        let view = WikiLinkPreviewView(
            title: title,
            previewText: content,
            appearance: appearance,
            colorScheme: colorScheme
        )
        
        let hosting = NSHostingView(rootView: AnyView(view))
        contentView = hosting
        hostingView = hosting
        
        // Position below the link
        let panelOrigin = CGPoint(x: point.x - 190, y: point.y - 310)
        setFrameOrigin(panelOrigin)
        
        if !isVisible {
            orderFront(nil)
        }
    }
    
    func hide() {
        orderOut(nil)
    }
}

// MARK: - SwiftUI Preview View

struct WikiLinkPreviewView: View {
    let title: String
    let previewText: String
    let appearance: ReaderAppearanceSettings
    let colorScheme: ColorScheme
    
    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title bar
            HStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 11))
                    .foregroundColor(colors.accent)
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(colors.primaryText)
                    .lineLimit(1)
                
                Spacer()
                
                Text("Preview")
                    .font(.system(size: 10))
                    .foregroundColor(colors.tertiaryText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(colors.secondarySurface))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(colors.sidebarBackground)
            
            Divider().background(colors.divider)
            
            // Preview content
            ScrollView {
                Text(previewText)
                    .font(.system(size: 12))
                    .foregroundColor(colors.secondaryText)
                    .lineSpacing(4)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(colors.readerBackground)
        }
        .frame(width: 380, height: 280)
        .background(colors.readerBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }
}
