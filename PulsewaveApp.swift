import SwiftUI

@main
struct PulsewaveApp: App {
    init() {
        ThemeStore.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
