import SwiftUI

// A theme pack is a shareable JSON file that replaces every color in the app plus
// the color scheme and font. The schema matches Jolly Roger's texture packs, so a
// pack exported from either app imports into the other. Pulsewave-only fields
// (`surface`) are optional and fall back to something sensible.

struct ThemePack: Codable, Identifiable, Hashable {
    struct Palette: Codable, Hashable {
        /// Page background gradient.
        var backgroundTop: String
        var backgroundBottom: String
        /// Flat fill for list screens and the tab bar.
        var solidBackground: String
        /// Buttons, links, selected tab, icons.
        var accent: String
        /// Secondary pop: toy art, level card, progress, unread dots.
        var highlight: String
        /// Banner bars (level card header, mode detail hero).
        var headerTop: String
        var headerBottom: String
        var headerText: String
        /// Card fill. Optional; derived from the color scheme when missing.
        var surface: String?
    }

    var id: String
    var name: String
    var author: String?
    /// "light", "dark", or nil to follow the system.
    var colorScheme: String?
    /// Any font installed on iOS or bundled in Resources/Fonts. Nil keeps the system font.
    var fontName: String?
    var headerCornerRadius: Double?
    /// Multiplier for the pack font's sizes (wide or tiny fonts need adjusting).
    var fontScale: Double?
    /// Which drawn style to use for cards and backdrops (see `PackStyle`).
    var chrome: String?
    var palette: Palette

    var preferredColorScheme: ColorScheme? {
        switch colorScheme?.lowercased() {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }

    var style: PackStyle { PackStyle(rawValue: chrome ?? "") ?? .plain }

    func color(_ key: KeyPath<Palette, String>) -> Color {
        Color(hex: palette[keyPath: key]) ?? .gray
    }
}

// MARK: - Built-in packs

extension ThemePack {
    /// Pulsewave's own look: black fading into violet, purple accent, orange pop.
    static let pulse = ThemePack(
        id: "builtin.pulse", name: "Pulse", author: "Pulsewave", colorScheme: "dark",
        fontName: nil, headerCornerRadius: 14, fontScale: nil, chrome: PackStyle.pulse.rawValue,
        palette: Palette(
            backgroundTop: "#000000", backgroundBottom: "#301740", solidBackground: "#0B0710",
            accent: "#BF5AF2", highlight: "#FF9F0A",
            headerTop: "#BF5AF2", headerBottom: "#6E2A9C", headerText: "#FFFFFF",
            surface: "#FFFFFF0F"
        )
    )

    private static func pack(
        _ style: PackStyle, name: String, scheme: String, font: String?, scale: Double = 1, radius: Double = 6,
        background: (String, String), solid: String, accent: String, highlight: String,
        header: (String, String, String), surface: String? = nil
    ) -> ThemePack {
        ThemePack(
            id: "builtin.\(style.rawValue)", name: name, author: "Jolly Roger", colorScheme: scheme,
            fontName: font, headerCornerRadius: radius, fontScale: scale, chrome: style.rawValue,
            palette: Palette(
                backgroundTop: background.0, backgroundBottom: background.1, solidBackground: solid,
                accent: accent, highlight: highlight,
                headerTop: header.0, headerBottom: header.1, headerText: header.2,
                surface: surface
            )
        )
    }

    // Ported from Jolly Roger. Ids match its built-ins so shared files line up.

    /// Luna-era Windows XP: beige window body, Start-menu blue, Luna blue accent.
    static let windowsXP = pack(.windowsXP, name: "Windows XP", scheme: "light", font: "PixelifySans-Regular",
        background: ("#ECE9D8", "#ECE9D8"), solid: "#D3E5FA", accent: "#0B5CD5", highlight: "#F5B800",
        header: ("#3D95FF", "#0050E6", "#FFFFFF"), surface: "#FFFFFF")
    /// Aperture test chamber: white panels, blue and orange portals.
    static let portal = pack(.portal, name: "Portal 2", scheme: "light", font: "Barlow-Regular",
        background: ("#F4F5F6", "#DDE0E3"), solid: "#EEF0F2", accent: "#1E9BFF", highlight: "#FF8A00",
        header: ("#FFFFFF", "#E6E8EA", "#2B2F33"), surface: "#FFFFFF")
    /// Factory floor: steel plates, hazard stripes, orange highlights.
    static let factorio = pack(.factorio, name: "Factorio", scheme: "dark", font: "TitilliumWeb-Regular",
        background: ("#3A393A", "#2A292A"), solid: "#313031", accent: "#FF9F1B", highlight: "#FFC34D",
        header: ("#5A5A5A", "#3E3D3E", "#FFE6C0"), surface: "#3A393A")
    /// Night-sky surface with blue inventory slots.
    static let terraria = pack(.terraria, name: "Terraria", scheme: "dark", font: "PixelifySans-Regular",
        background: ("#0E1A40", "#2E4C8C"), solid: "#1B2A5A", accent: "#FFE45C", highlight: "#FFE45C",
        header: ("#3F51B5", "#2A3A8F", "#FFFFFF"), surface: "#34449CD9")
    /// A galaxy far, far away: star field, crawl yellow.
    static let starWars = pack(.starWars, name: "Star Wars", scheme: "dark", font: "Orbitron-Regular", scale: 0.82,
        background: ("#000000", "#05060A"), solid: "#000000", accent: "#FFE81F", highlight: "#FFE81F",
        header: ("#111111", "#000000", "#FFE81F"), surface: "#000000B3")
    /// Camera body: pebbled grip, LCD readouts, red accents.
    static let canon = pack(.canon, name: "Canon Camera", scheme: "dark", font: "ShareTechMono-Regular",
        background: ("#1A1A1A", "#0E0E0E"), solid: "#151515", accent: "#E0201B", highlight: "#E0201B",
        header: ("#1C2421", "#141A18", "#FFFFFF"), surface: "#1C2421")
    /// Jolly Roger's own: parchment, wooden planks, gold doubloons.
    static let pirate = pack(.pirate, name: "Pirate", scheme: "light", font: "PirataOne-Regular", scale: 1.15,
        background: ("#EBD8AE", "#D2AE70"), solid: "#E2C892", accent: "#8B1A1A", highlight: "#C9A227",
        header: ("#F1DFB0", "#D9BE85", "#5A1010"), surface: "#F1DFB0")
    /// Blocky dirt and stone buttons.
    static let minecraft = pack(.minecraft, name: "Minecraft", scheme: "dark", font: "Monocraft", scale: 0.82,
        background: ("#4A3422", "#3A2818"), solid: "#3A2818", accent: "#55FF55", highlight: "#FFFF55",
        header: ("#8B8B8B", "#6F6F6F", "#FFFFFF"), surface: "#6F6F6F")
    /// Etherium space: nebulae, gold stars, brass fittings.
    static let treasurePlanet = pack(.treasurePlanet, name: "Treasure Planet", scheme: "dark", font: "CinzelDecorative-Regular", scale: 0.88,
        background: ("#0B0A24", "#1B1240"), solid: "#12102E", accent: "#E2C275", highlight: "#E2C275",
        header: ("#E2C275", "#9C7A2E", "#3A2A0A"), surface: "#1B1240D9")
    /// Steam client: dark navy panels, light-blue accents.
    static let steam = pack(.steam, name: "Steam", scheme: "dark", font: nil,
        background: ("#1B2838", "#16202D"), solid: "#171A21", accent: "#66C0F4", highlight: "#66C0F4",
        header: ("#2A475E", "#1B2838", "#C7D5E0"), surface: "#16202DE6")
}

/// The drawn look a pack's `chrome` value switches on: card panels, background
/// texture, and display font. Imported packs with an unknown chrome get `.plain`.
enum PackStyle: String, CaseIterable {
    case pulse, plain, windowsXP, portal, factorio, terraria, starWars, canon, pirate, minecraft, treasurePlanet, steam

    /// Display font for big titles and card headings, at `size` points.
    func titleFont(_ size: CGFloat, pack: ThemePack) -> Font {
        switch self {
        case .portal: return .custom("Barlow-Bold", size: size)
        case .factorio: return .custom("TitilliumWeb-Bold", size: size)
        case .terraria, .windowsXP: return .custom("PixelifySans-Regular", size: size).weight(.bold)
        case .starWars: return .custom("Orbitron-Regular", size: size * 0.85).weight(.bold)
        case .canon: return .custom("ShareTechMono-Regular", size: size)
        case .pirate: return .custom("PirataOne-Regular", size: size * 1.2)
        case .minecraft: return .custom("Monocraft-Bold", size: size * 0.85)
        case .treasurePlanet: return .custom("CinzelDecorative-Bold", size: size * 0.82)
        case .steam: return .system(size: size * 0.9, weight: .semibold)
        case .pulse: return .system(size: size, weight: .bold, design: .rounded)
        case .plain:
            if let name = pack.fontName { return .custom(name, size: size * CGFloat(pack.fontScale ?? 1)).weight(.bold) }
            return .system(size: size, weight: .bold)
        }
    }
}

extension Color {
    /// Accepts "#RRGGBB", "RRGGBB", "#RRGGBBAA", or "RRGGBBAA".
    init?(hex: String) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") { string.removeFirst() }
        guard string.count == 6 || string.count == 8, let value = UInt64(string, radix: 16) else { return nil }
        let hasAlpha = string.count == 8
        let r = Double((value >> (hasAlpha ? 24 : 16)) & 0xFF) / 255
        let g = Double((value >> (hasAlpha ? 16 : 8)) & 0xFF) / 255
        let b = Double((value >> (hasAlpha ? 8 : 0)) & 0xFF) / 255
        let a = hasAlpha ? Double(value & 0xFF) / 255 : 1
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Force-unwrapped hex for literals that are known-good.
    static func hex(_ string: String) -> Color { Color(hex: string) ?? .gray }
}
