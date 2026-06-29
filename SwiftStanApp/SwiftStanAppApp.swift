import SwiftUI
import AppIntents

@main
struct SwiftStanAppApp: App {
    init() {
        SwiftStanShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            StanCommandView()
        }
        .defaultSize(width: 640, height: 720)

#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
