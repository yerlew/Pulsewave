# Theme packs

A theme pack swaps every color, the color scheme, the font, card panels and the
background texture in one go. Pick one under **Me → Theme Packs**.

- `ThemePack.swift`: the pack model, the built-in packs, and `PackStyle` (the drawn look a pack's `chrome` value turns on).
- `ThemeStore.swift`: the equipped pack, imported packs, import/export, font registration.
- `ThemeStyles.swift`: `.themedBackground()`, `.themedCard()`, `Font.themed(_:)`, `ThemedHeader`, `.themedInlineTitle(_:)`, and the ported card panels and backdrops.

Built in: **Pulse** (default, the original look) plus the ten packs ported from
Jolly Roger: Windows XP, Portal 2, Factorio, Terraria, Star Wars, Canon Camera,
Pirate, Minecraft, Treasure Planet, Steam.

## Using it in a view

Read `ThemeStore.shared.current` in `body` (Observation redraws on change) and
use its tokens instead of literal colors: `accent`, `highlight`, `surface`,
`headerGradient`, `headerText`, `font(_:)`, `style.titleFont(_:pack:)`.
Tab roots draw a `ThemedHeader` and call `.themedRootScreen(title)`; pushed
screens call `.themedInlineTitle(title)`. UIKit nav titles can't take a custom
font live, which is why titles are drawn by hand.

## Pack files

Same JSON schema as Jolly Roger's texture packs, so files move between the apps.
`palette.surface` (card fill) is Pulsewave-only and optional.

```json
{
  "id": "me.neon",
  "name": "Neon",
  "author": "you",
  "colorScheme": "dark",
  "fontName": "Orbitron-Regular",
  "fontScale": 0.85,
  "palette": {
    "backgroundTop": "#05010F", "backgroundBottom": "#1A0433",
    "solidBackground": "#0A0218",
    "accent": "#00F0FF", "highlight": "#FF2BD6",
    "headerTop": "#FF2BD6", "headerBottom": "#7A00FF", "headerText": "#FFFFFF",
    "surface": "#FFFFFF14"
  }
}
```

Colors are `#RRGGBB` or `#RRGGBBAA`. Leave `chrome` out for the plain rounded
cards, or set it to a built-in style name (`portal`, `pirate`, …) to borrow that
look.

## Xcode setup

Add `Resources/Fonts` to the app target (as a group, so the font files land at
the bundle root). They're registered at launch by
`ThemeStore.registerBundledFonts()`, so no `UIAppFonts` Info.plist entry is
needed. All fonts are SIL OFL; licenses sit next to them.
