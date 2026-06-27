import SwiftUI
import AppIntents

@main
struct SwiftStanAppApp: App {
  init() {
    SwiftStanShortcuts.updateAppShortcutParameters()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .defaultSize(width: 480, height: 220)
  }
}
