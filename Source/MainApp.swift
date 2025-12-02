import SFSafeSymbols
import Sentry
import SwiftUI

@main
struct MainApp: App {
    private let metricsCollector = SystemMetricsCollector(collectionInterval: 1.0)

    init() {
        // Initializing the Sentry SDK
        SentrySDK.start { options in
            options.dsn = Globals.sentryDsn
            options.debug = true
            options.sendDefaultPii = true
        }

        // Start collecting metrics when the app launches
        metricsCollector.start()
    }

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
