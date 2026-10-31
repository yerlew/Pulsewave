import SwiftUI
import Observation
import CoreText

enum ThemePackError: LocalizedError {
    case invalidColor(field: String, value: String)
    case missingName

    var errorDescription: String? {
        switch self {
        case let .invalidColor(field, value):
            return "\"\(value)\" isn't a valid color for \(field). Use a hex color like #1A2B3C."
        case .missingName:
            return "The theme pack needs a name."
        }
    }
}

/// Holds the equipped pack and any imported ones. Built-in packs live in code;
/// imported packs and the selection are saved to UserDefaults. Views read
/// `ThemeStore.shared.current`, which Observation tracks, so swapping packs redraws.
@MainActor
@Observable
final class ThemeStore {
    static let shared = ThemeStore()

    static let builtInPacks: [ThemePack] = [
        .pulse, .windowsXP, .portal, .factorio, .terraria, .starWars, .canon, .pirate, .minecraft, .treasurePlanet, .steam,
    ]

    private enum Keys {
        static let activePackID = "activeThemePackID"
        static let customPacks = "customThemePacks"
    }

    private(set) var customPacks: [ThemePack] = []
    private(set) var activePackID: String

    var allPacks: [ThemePack] { Self.builtInPacks + customPacks }
    /// Never nil: falls back to Pulse if the saved id went missing.
    var current: ThemePack { allPacks.first { $0.id == activePackID } ?? .pulse }

    private init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: Keys.customPacks),
           let packs = try? JSONDecoder().decode([ThemePack].self, from: data) {
            customPacks = packs
        }
        activePackID = defaults.string(forKey: Keys.activePackID) ?? ThemePack.pulse.id
    }

    func isBuiltIn(_ pack: ThemePack) -> Bool {
        Self.builtInPacks.contains { $0.id == pack.id }
    }

    func activate(_ id: String) {
        activePackID = id
        UserDefaults.standard.set(id, forKey: Keys.activePackID)
    }

    /// Decodes and validates a pack file, saves it, and equips it. A pack whose id
    /// matches an imported pack replaces it; one that collides with a built-in gets
    /// a fresh id so it can't shadow it.
    @discardableResult
    func importPack(from data: Data) throws -> ThemePack {
        var pack = try JSONDecoder().decode(ThemePack.self, from: data)
        try Self.validate(pack)
        if pack.id.isEmpty || isBuiltIn(pack) {
            pack.id = "imported.\(UUID().uuidString)"
        }
        if let index = customPacks.firstIndex(where: { $0.id == pack.id }) {
            customPacks[index] = pack
        } else {
            customPacks.append(pack)
        }
        saveCustomPacks()
        activate(pack.id)
        return pack
    }

    func exportData(for pack: ThemePack) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(pack)
    }

    func delete(_ pack: ThemePack) {
        guard !isBuiltIn(pack) else { return }
        customPacks.removeAll { $0.id == pack.id }
        saveCustomPacks()
        if activePackID == pack.id { activate(ThemePack.pulse.id) }
    }

    private func saveCustomPacks() {
        if let data = try? JSONEncoder().encode(customPacks) {
            UserDefaults.standard.set(data, forKey: Keys.customPacks)
        }
    }

    private static func validate(_ pack: ThemePack) throws {
        guard !pack.name.trimmingCharacters(in: .whitespaces).isEmpty else { throw ThemePackError.missingName }
        let p = pack.palette
        var fields: [(String, String)] = [
            ("backgroundTop", p.backgroundTop), ("backgroundBottom", p.backgroundBottom),
            ("solidBackground", p.solidBackground), ("accent", p.accent), ("highlight", p.highlight),
            ("headerTop", p.headerTop), ("headerBottom", p.headerBottom), ("headerText", p.headerText),
        ]
        if let surface = p.surface { fields.append(("surface", surface)) }
        for (field, value) in fields where Color(hex: value) == nil {
            throw ThemePackError.invalidColor(field: field, value: value)
        }
    }

    // MARK: - Fonts

    /// Registers the bundled pack fonts (SIL OFL, licenses in Resources/Fonts) so
    /// no Info.plist `UIAppFonts` entry is needed. Call once at launch.
    static func registerBundledFonts() {
        for ext in ["ttf", "otf"] {
            for url in Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [] {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
