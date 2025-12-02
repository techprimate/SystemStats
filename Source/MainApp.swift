import SFSafeSymbols
import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        // Create the menu bar item for the application
        MenuBarExtra(
            "menu.title",
            systemSymbol: .eyes
        ) {
            MenuContentView()
        }
        .menuBarExtraStyle(.automatic)
        // Create a default macOS app settings dialog
        Settings {
            SettingsView()
        }
    }
}
