import SwiftUI

struct ThemeBackgroundView: View {
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let theme = SceneTheme.theme(for: appearance.current.sceneThemeID)
        
        ZStack {
            // Base background
            theme.appBackground
                .ignoresSafeArea()
            
            // Custom local background image (if set)
            if let bookmark = appearance.current.customBackgroundBookmark,
               let nsImage = resolveBookmark(bookmark) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(appearance.current.customBackgroundOpacity)
                    .blur(radius: appearance.current.customBackgroundBlur)
                    .ignoresSafeArea()
                    .blendMode(theme.isDark ? .screen : .multiply)
            } else {
                // Procedural custom background layer
                switch theme.backgroundType {
                case .none:
                    EmptyView()
                case .warmNoise:
                    WarmNoiseBackground()
                case .aurora:
                    AuroraBackground()
                case .stars:
                    StarsBackground()
                case .blueprint:
                    BlueprintBackground()
                case .forest:
                    ForestBackground()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func resolveBookmark(_ data: Data) -> NSImage? {
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            guard url.startAccessingSecurityScopedResource() else { return nil }
            defer { url.stopAccessingSecurityScopedResource() }
            return NSImage(contentsOf: url)
        } catch {
            return nil
        }
    }
}

// MARK: - Specific Backgrounds

struct AuroraBackground: View {
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0x8C78ED).opacity(0.3), .clear]),
                center: .topLeading,
                startRadius: 100,
                endRadius: 800
            )
            
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0x5AC8FA).opacity(0.2), .clear]),
                center: .bottomTrailing,
                startRadius: 100,
                endRadius: 600
            )
        }
        .ignoresSafeArea()
    }
}

struct WarmNoiseBackground: View {
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0xC47D2E).opacity(0.05), .clear]),
                center: .center,
                startRadius: 50,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}

struct StarsBackground: View {
    var body: some View {
        Canvas { context, size in
            let count = 200
            var seededGen = SeededRandomNumberGenerator(seed: 42)
            
            for _ in 0..<count {
                let x = CGFloat.random(in: 0...size.width, using: &seededGen)
                let y = CGFloat.random(in: 0...size.height, using: &seededGen)
                let radius = CGFloat.random(in: 0.5...1.5, using: &seededGen)
                let opacity = Double.random(in: 0.2...0.8, using: &seededGen)
                
                let rect = CGRect(x: x, y: y, width: radius * 2, height: radius * 2)
                context.opacity = opacity
                context.fill(Path(ellipseIn: rect), with: .color(Color(hex: 0xE7E5DF)))
            }
        }
        .ignoresSafeArea()
    }
}

struct BlueprintBackground: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 40
            let linesColor = Color(hex: 0x5AC8FA).opacity(0.15)
            
            var path = Path()
            
            // Vertical lines
            var x: CGFloat = 0
            while x < size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            
            // Horizontal lines
            var y: CGFloat = 0
            while y < size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            
            context.stroke(path, with: .color(linesColor), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

struct ForestBackground: View {
    var body: some View {
        Canvas { context, size in
            let curvesColor = Color(hex: 0x7CC27C).opacity(0.08)
            var seededGen = SeededRandomNumberGenerator(seed: 123)
            
            for i in 0..<15 {
                var path = Path()
                let startY = CGFloat.random(in: -100...size.height+100, using: &seededGen)
                path.move(to: CGPoint(x: -50, y: startY))
                
                let cp1x = size.width * 0.33
                let cp1y = startY + CGFloat.random(in: -200...200, using: &seededGen)
                
                let cp2x = size.width * 0.66
                let cp2y = startY + CGFloat.random(in: -200...200, using: &seededGen)
                
                let endY = startY + CGFloat.random(in: -100...100, using: &seededGen)
                
                path.addCurve(to: CGPoint(x: size.width + 50, y: endY),
                              control1: CGPoint(x: cp1x, y: cp1y),
                              control2: CGPoint(x: cp2x, y: cp2y))
                
                context.stroke(path, with: .color(curvesColor), lineWidth: 1.5)
            }
        }
        .ignoresSafeArea()
    }
}

// Simple seeded PRNG for consistent backgrounds
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z &>> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z &>> 27)) &* 0x94D049BB133111EB
        return z ^ (z &>> 31)
    }
}
