import SwiftUI

enum LightMDIcon {
    // Custom Shapes
    case workspace
    case highlight
    case underline
    case memo
    case splitPane
    case more
    case page
    case folder
    case folderOpen
    case search
    case textFormat
    
    // SF Symbols mapped to specific thin styles
    case chevronLeft
    case chevronRight
    case chevronDown
    case chevronUp
    case command
    case back
    case forward
    case save
    case star
    case starFilled
    case close
    case plus
    case checkmark
    case eraser
    case palette
    case sidebarRight
    case sidebarLeft
    case bookmark
}

struct AppIcon: View {
    let icon: LightMDIcon
    var size: CGFloat = IconMetrics.toolbarSize
    var weight: Font.Weight = .light
    
    var body: some View {
        Group {
            switch icon {
            case .workspace: WorkspaceShape().stroke(style: strokeStyle).background(Color.clear)
            case .highlight: HighlightShape().stroke(style: strokeStyle).background(Color.clear)
            case .underline: UnderlineShape().stroke(style: strokeStyle).background(Color.clear)
            case .memo: MemoShape().stroke(style: strokeStyle).background(Color.clear)
            case .splitPane: SplitPaneShape().stroke(style: strokeStyle).background(Color.clear)
            case .more: MoreShape().fill(Color.primary)
            case .page: PageShape().stroke(style: strokeStyle).background(Color.clear)
            case .folder: FolderShape(isOpen: false).stroke(style: strokeStyle).background(Color.clear)
            case .folderOpen: FolderShape(isOpen: true).stroke(style: strokeStyle).background(Color.clear)
            case .search: symbol("magnifyingglass")
            case .textFormat: symbol("textformat")
                
            case .chevronLeft: symbol("chevron.left")
            case .chevronRight: symbol("chevron.right")
            case .chevronDown: symbol("chevron.down")
            case .chevronUp: symbol("chevron.up")
            case .command: symbol("command")
            case .back: symbol("arrow.left")
            case .forward: symbol("arrow.right")
            case .save: symbol("arrow.down.to.line")
            case .star: symbol("star")
            case .starFilled: symbol("star.fill")
            case .close: symbol("xmark")
            case .plus: symbol("plus")
            case .checkmark: symbol("checkmark")
            case .eraser: symbol("eraser")
            case .palette: symbol("paintpalette")
            case .sidebarRight: symbol("sidebar.right")
            case .sidebarLeft: symbol("sidebar.left")
            case .bookmark: symbol("bookmark")
            }
        }
        .frame(width: size, height: size)
    }
    
    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: IconMetrics.strokeWidth, lineCap: .round, lineJoin: .round)
    }
    
    @ViewBuilder
    private func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: size, weight: weight, design: .default))
    }
}

// MARK: - Shapes

struct WorkspaceShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let gap: CGFloat = rect.width * 0.15
        let s = (rect.width - gap) / 2
        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: s, height: s), cornerSize: CGSize(width: 2, height: 2))
        path.addRoundedRect(in: CGRect(x: s + gap, y: 0, width: s, height: s), cornerSize: CGSize(width: 2, height: 2))
        path.addRoundedRect(in: CGRect(x: 0, y: s + gap, width: s, height: s), cornerSize: CGSize(width: 2, height: 2))
        path.addRoundedRect(in: CGRect(x: s + gap, y: s + gap, width: s, height: s), cornerSize: CGSize(width: 2, height: 2))
        return path
    }
}

struct HighlightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Pen body
        path.move(to: CGPoint(x: w * 0.2, y: h * 0.8))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.2))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.3))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.9))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.8))
        
        // Nib line
        path.move(to: CGPoint(x: w * 0.3, y: h * 0.7))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.8))
        
        // Highlight line
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w, y: h))
        
        return path
    }
}

struct UnderlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // U shape
        path.move(to: CGPoint(x: w * 0.25, y: h * 0.1))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.5))
        path.addArc(center: CGPoint(x: w * 0.5, y: h * 0.5), radius: w * 0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.1))
        
        // Line
        path.move(to: CGPoint(x: w * 0.1, y: h * 0.9))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.9))
        
        return path
    }
}

struct MemoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let corner = w * 0.3
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w - corner, y: 0))
        path.addLine(to: CGPoint(x: w, y: corner))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        
        // Fold
        path.move(to: CGPoint(x: w - corner, y: 0))
        path.addLine(to: CGPoint(x: w - corner, y: corner))
        path.addLine(to: CGPoint(x: w, y: corner))
        
        return path
    }
}

struct SplitPaneShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h), cornerSize: CGSize(width: 2, height: 2))
        path.move(to: CGPoint(x: w * 0.65, y: 0))
        path.addLine(to: CGPoint(x: w * 0.65, y: h))
        
        return path
    }
}

struct MoreShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r: CGFloat = 1.5
        let cy = rect.height / 2
        path.addEllipse(in: CGRect(x: rect.width * 0.2 - r, y: cy - r, width: r*2, height: r*2))
        path.addEllipse(in: CGRect(x: rect.width * 0.5 - r, y: cy - r, width: r*2, height: r*2))
        path.addEllipse(in: CGRect(x: rect.width * 0.8 - r, y: cy - r, width: r*2, height: r*2))
        return path
    }
}

struct PageShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let px = w * 0.2
        let py = h * 0.1
        
        path.addRoundedRect(in: CGRect(x: px, y: py, width: w - px*2, height: h - py*2), cornerSize: CGSize(width: 2, height: 2))
        return path
    }
}

struct FolderShape: Shape {
    let isOpen: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let tabW = w * 0.4
        let tabH = h * 0.2
        
        path.move(to: CGPoint(x: 0, y: tabH))
        path.addLine(to: CGPoint(x: tabW, y: tabH))
        path.addLine(to: CGPoint(x: tabW + tabH, y: tabH * 2))
        path.addLine(to: CGPoint(x: w, y: tabH * 2))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        
        return path
    }
}
