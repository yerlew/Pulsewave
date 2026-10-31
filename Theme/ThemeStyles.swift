import SwiftUI

// View-side helpers: the themed page background, card panels, fonts, and the
// banner gradient. Card panels and backdrops are ported from Jolly Roger's skins.

extension ThemePack {
    var accent: Color { color(\.accent) }
    var highlight: Color { color(\.highlight) }
    var headerText: Color { color(\.headerText) }
    var headerGradient: LinearGradient {
        LinearGradient(colors: [color(\.headerTop), color(\.headerBottom)], startPoint: .top, endPoint: .bottom)
    }

    /// Card fill; derived from the scheme when the pack doesn't set one.
    var surface: Color {
        if let hex = palette.surface, let color = Color(hex: hex) { return color }
        return preferredColorScheme == .light ? .black.opacity(0.05) : .white.opacity(0.06)
    }

    /// The pack's font at the size iOS uses for `style`, or the system text style.
    func font(_ style: Font.TextStyle) -> Font {
        guard let name = fontName else { return .system(style) }
        let size: CGFloat
        switch style {
        case .largeTitle: size = 34
        case .title: size = 28
        case .title2: size = 22
        case .title3: size = 20
        case .headline, .body: size = 17
        case .callout: size = 16
        case .subheadline: size = 15
        case .footnote: size = 13
        case .caption: size = 12
        case .caption2: size = 11
        @unknown default: size = 17
        }
        let font = Font.custom(name, size: size * CGFloat(fontScale ?? 1), relativeTo: style)
        return style == .headline ? font.weight(.semibold) : font
    }
}

extension Font {
    /// Shorthand for the equipped pack's font.
    @MainActor static func themed(_ style: Font.TextStyle) -> Font { ThemeStore.shared.current.font(style) }
}

// MARK: - Page background

struct ThemedBackgroundModifier: ViewModifier {
    /// Flat `solidBackground` instead of the gradient (list-heavy screens).
    var solid = false

    func body(content: Content) -> some View {
        let pack = ThemeStore.shared.current
        return content
            .scrollContentBackground(.hidden)
            .background {
                ZStack {
                    if solid {
                        pack.color(\.solidBackground)
                    } else {
                        LinearGradient(colors: [pack.color(\.backgroundTop), pack.color(\.backgroundBottom)],
                                       startPoint: .top, endPoint: .bottom)
                    }
                    PackBackdrop(style: pack.style)
                }
                .ignoresSafeArea()
            }
    }
}

extension View {
    func themedBackground(solid: Bool = false) -> some View {
        modifier(ThemedBackgroundModifier(solid: solid))
    }

    /// Puts the content on the pack's card panel.
    func themedCard(cornerRadius: CGFloat = 14) -> some View {
        background { PackSurface(cornerRadius: cornerRadius) }
    }
}

// MARK: - Card panels

struct PackSurface: View {
    var pack: ThemePack = ThemeStore.shared.current
    /// Only `.pulse` / `.plain` panels honor this; the drawn styles keep their own shape.
    var cornerRadius: CGFloat = 14
    var highlighted = false

    var body: some View {
        switch pack.style {
        case .windowsXP:
            RoundedRectangle(cornerRadius: 6).fill(.white)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.hex(highlighted ? "#0B5CD5" : "#7A96DF"), lineWidth: highlighted ? 2 : 1))
        case .portal:
            RoundedRectangle(cornerRadius: 8).fill(.white)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(highlighted ? pack.accent : Color.hex("#C9CDD1"), lineWidth: highlighted ? 2 : 1))
                .shadow(color: highlighted ? pack.accent.opacity(0.5) : .clear, radius: 5)
        case .factorio:
            Rectangle().fill(Color.hex("#3A393A"))
                .overlay(Rectangle().stroke(highlighted ? pack.accent : Color.black.opacity(0.7), lineWidth: 2))
                .overlay(alignment: .top) { Color.white.opacity(0.08).frame(height: 1).padding(2) }
        case .terraria:
            RoundedRectangle(cornerRadius: 8).fill(Color.hex("#34449C").opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(highlighted ? pack.accent : Color.hex("#10153A"), lineWidth: highlighted ? 2.5 : 2))
        case .starWars:
            Rectangle().fill(Color.black.opacity(0.7))
                .overlay(Rectangle().stroke(Color.hex("#FFE81F").opacity(highlighted ? 1 : 0.35), lineWidth: 1))
        case .canon:
            RoundedRectangle(cornerRadius: 6).fill(Color.hex("#1C2421"))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(highlighted ? pack.accent : Color.hex("#3A4A44"), lineWidth: highlighted ? 2 : 1))
        case .pirate:
            RoundedRectangle(cornerRadius: 4).fill(Color.hex("#F1DFB0"))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(highlighted ? pack.accent : Color.hex("#6B4226"), lineWidth: 1.5))
        case .minecraft:
            MinecraftBevel(face: Color.hex(highlighted ? "#7A86C4" : "#6F6F6F"), highlighted: highlighted)
        case .treasurePlanet:
            RoundedRectangle(cornerRadius: 10).fill(Color.hex("#1B1240").opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.hex("#E2C275").opacity(highlighted ? 1 : 0.7), lineWidth: 1))
        case .steam:
            Rectangle().fill(Color.hex("#16202D").opacity(0.9))
                .overlay(alignment: .bottom) { Color.black.opacity(0.3).frame(height: 1) }
                .overlay(Rectangle().stroke(highlighted ? pack.accent : .clear, lineWidth: 1))
        case .pulse, .plain:
            RoundedRectangle(cornerRadius: cornerRadius).fill(pack.surface)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(highlighted ? pack.accent : .clear, lineWidth: 1.5))
        }
    }
}

/// Minecraft-style stone button bevel.
struct MinecraftBevel: View {
    var face: Color = .hex("#8B8B8B")
    var highlighted = false

    var body: some View {
        ZStack {
            Color.black
            ZStack(alignment: .topLeading) {
                Color.hex("#3F3F3F")
                Color.white.opacity(0.55)
                    .padding(.trailing, 3).padding(.bottom, 3)
                face
                    .padding(3)
            }
            .padding(2)
            if highlighted {
                Rectangle().stroke(Color.white, lineWidth: 2).padding(1)
            }
        }
    }
}

// MARK: - Background textures

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// Procedural texture drawn over a pack's background gradient.
struct PackBackdrop: View {
    let style: PackStyle

    var body: some View {
        Canvas(rendersAsynchronously: true) { context, size in
            var rng = SeededGenerator(seed: 42)
            func randomPoint() -> CGPoint {
                CGPoint(x: CGFloat.random(in: 0...size.width, using: &rng), y: CGFloat.random(in: 0...size.height, using: &rng))
            }

            switch style {
            case .pulse:
                // Faint concentric rings radiating from the top, like a sonar ping.
                let center = CGPoint(x: size.width / 2, y: size.height * 0.18)
                for i in 1...7 {
                    let r = CGFloat(i) * size.width * 0.16
                    context.stroke(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
                                   with: .color(Color.hex("#BF5AF2").opacity(0.07 - Double(i) * 0.008)), lineWidth: 1)
                }

            case .portal:
                // Test-chamber wall panels.
                let panel: CGFloat = 64
                var path = Path()
                var x: CGFloat = 0
                while x < size.width { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)); x += panel }
                var y: CGFloat = 0
                while y < size.height { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)); y += panel }
                context.stroke(path, with: .color(.black.opacity(0.07)), lineWidth: 1)

            case .factorio:
                // Riveted steel floor plates.
                let plate: CGFloat = 56
                for row in 0...Int(size.height / plate) {
                    for col in 0...Int(size.width / plate) {
                        let rect = CGRect(x: CGFloat(col) * plate, y: CGFloat(row) * plate, width: plate, height: plate)
                        context.stroke(Path(rect.insetBy(dx: 1, dy: 1)), with: .color(.black.opacity(0.35)), lineWidth: 2)
                        context.stroke(Path(rect.insetBy(dx: 3, dy: 3)), with: .color(.white.opacity(0.04)), lineWidth: 1)
                        for corner in [CGPoint(x: rect.minX + 7, y: rect.minY + 7), CGPoint(x: rect.maxX - 7, y: rect.minY + 7),
                                       CGPoint(x: rect.minX + 7, y: rect.maxY - 7), CGPoint(x: rect.maxX - 7, y: rect.maxY - 7)] {
                            context.fill(Path(ellipseIn: CGRect(x: corner.x - 1.5, y: corner.y - 1.5, width: 3, height: 3)), with: .color(.white.opacity(0.12)))
                        }
                    }
                }

            case .terraria:
                // Pixel stars.
                for _ in 0..<90 {
                    let s: CGFloat = Bool.random(using: &rng) ? 2 : 3
                    let p = randomPoint()
                    context.fill(Path(CGRect(x: p.x, y: p.y, width: s, height: s)), with: .color(.white.opacity(Double.random(in: 0.3...0.9, using: &rng))))
                }

            case .starWars, .treasurePlanet:
                if style == .treasurePlanet {
                    // Etherium nebula glows.
                    for (color, center, radius) in [(Color.hex("#5B2A86"), CGPoint(x: 0.2, y: 0.25), 0.55),
                                                    (Color.hex("#1D4E89"), CGPoint(x: 0.85, y: 0.55), 0.6),
                                                    (Color.hex("#1F7A7A"), CGPoint(x: 0.4, y: 0.9), 0.45)] {
                        let c = CGPoint(x: center.x * size.width, y: center.y * size.height)
                        let r = radius * size.width
                        context.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                                     with: .radialGradient(Gradient(colors: [color.opacity(0.55), .clear]), center: c, startRadius: 0, endRadius: r))
                    }
                }
                let starColor = style == .treasurePlanet ? Color.hex("#F3D98B") : .white
                for _ in 0..<(style == .starWars ? 220 : 120) {
                    let s = CGFloat.random(in: 0.6...2.2, using: &rng)
                    let p = randomPoint()
                    context.fill(Path(ellipseIn: CGRect(x: p.x, y: p.y, width: s, height: s)),
                                 with: .color(starColor.opacity(Double.random(in: 0.25...1, using: &rng))))
                }
                if style == .treasurePlanet {
                    // A few four-point sparkles.
                    for _ in 0..<10 {
                        let p = randomPoint()
                        let r = CGFloat.random(in: 4...8, using: &rng)
                        var sparkle = Path()
                        sparkle.move(to: CGPoint(x: p.x, y: p.y - r))
                        sparkle.addQuadCurve(to: CGPoint(x: p.x + r, y: p.y), control: p)
                        sparkle.addQuadCurve(to: CGPoint(x: p.x, y: p.y + r), control: p)
                        sparkle.addQuadCurve(to: CGPoint(x: p.x - r, y: p.y), control: p)
                        sparkle.addQuadCurve(to: CGPoint(x: p.x, y: p.y - r), control: p)
                        context.fill(sparkle, with: .color(starColor.opacity(0.85)))
                    }
                }

            case .canon:
                // Pebbled leatherette grip.
                for _ in 0..<4500 {
                    let p = randomPoint()
                    let s = CGFloat.random(in: 1.5...3.5, using: &rng)
                    let light = Bool.random(using: &rng)
                    context.fill(Path(ellipseIn: CGRect(x: p.x, y: p.y, width: s, height: s)),
                                 with: .color(light ? .white.opacity(0.05) : .black.opacity(0.35)))
                }

            case .pirate:
                // Parchment stains and a dark vignette.
                for _ in 0..<40 {
                    let p = randomPoint()
                    let r = CGFloat.random(in: 15...80, using: &rng)
                    context.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                                 with: .radialGradient(Gradient(colors: [Color.hex("#8B5A2B").opacity(Double.random(in: 0.04...0.1, using: &rng)), .clear]),
                                                       center: p, startRadius: 0, endRadius: r))
                }
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                context.fill(Path(CGRect(origin: .zero, size: size)),
                             with: .radialGradient(Gradient(colors: [.clear, Color.hex("#5A3410").opacity(0.45)]),
                                                   center: c, startRadius: size.width * 0.45, endRadius: size.height * 0.75))

            case .minecraft:
                // Dirt blocks, darkened so text stays readable.
                let px: CGFloat = 5
                let palette = ["#866043", "#6C4B30", "#9A6E4E", "#5E4129", "#79553A"].map(Color.hex)
                for row in 0..<Int(size.height / px) + 1 {
                    for col in 0..<Int(size.width / px) + 1 {
                        let color = palette[Int.random(in: 0..<palette.count, using: &rng)]
                        context.fill(Path(CGRect(x: CGFloat(col) * px, y: CGFloat(row) * px, width: px, height: px)), with: .color(color))
                    }
                }
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.45)))

            case .steam:
                let c = CGPoint(x: size.width * 0.5, y: -size.height * 0.05)
                context.fill(Path(CGRect(origin: .zero, size: size)),
                             with: .radialGradient(Gradient(colors: [Color.hex("#2A475E").opacity(0.9), .clear]),
                                                   center: c, startRadius: 0, endRadius: size.height * 0.6))

            case .windowsXP, .plain:
                break
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Titles

// Navigation bar titles are UIKit-drawn and won't take a custom font live, so the
// tab roots draw their own large header and pushed screens put a themed title in
// the principal toolbar slot.

/// Large page title in the pack's display font, for the top of a tab root.
struct ThemedHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        let pack = ThemeStore.shared.current
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(pack.style.titleFont(34, pack: pack))
                .foregroundStyle(pack.style == .starWars ? pack.accent : .primary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            trailing
        }
    }
}

extension ThemedHeader where Trailing == EmptyView {
    init(_ title: String) {
        self.title = title
        self.trailing = EmptyView()
    }
}

extension View {
    /// Inline navigation title drawn in the pack's display font.
    func themedInlineTitle(_ title: String) -> some View {
        let pack = ThemeStore.shared.current
        return navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(pack.style.titleFont(17, pack: pack))
                        .foregroundStyle(pack.style == .starWars ? pack.accent : .primary)
                        .lineLimit(1)
                }
            }
    }

    /// Hides the system bar on a tab root that draws its own `ThemedHeader`.
    func themedRootScreen(_ title: String) -> some View {
        navigationTitle(title)
            .toolbar(.hidden, for: .navigationBar)
    }
}
