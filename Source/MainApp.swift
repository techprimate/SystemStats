import SFSafeSymbols
import SentrySwift
import SwiftUI

@main
struct MainApp: App {
    @AppStorage(AppStorageKeys.Settings.customDeviceName) private var customDeviceName = ""

    private let metricsCollector = SystemMetricsCollector(collectionInterval: 1.0)

    init() {
        // Initializing the Sentry SDK
        SentrySDK.start { options in
            options.dsn = Globals.sentryDsn
            options.debug = true

            let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            options.releaseName = "\(bundleId ?? "unknown")@\(version ?? "unknown")+\(build ?? "unknown")"

            options.environment = Env.pickEnvValue(production: "production", develop: "development")
            options.sampleRate = Env.pickEnvValue(production: 0.2, develop: 1.0)
            options.tracesSampleRate = Env.pickEnvValue(production: 0.2, develop: 1.0)

            // Configure General Options
            options.sendDefaultPii = true
            options.enableAutoBreadcrumbTracking = false
            options.enableMetricKit = false
            options.enableTimeToFullDisplayTracing = false
            options.enableSwizzling = false
            options.swiftAsyncStacktraces = false

            // Configure Crash Reporting
            options.enableCrashHandler = false
            options.enableSigtermReporting = false
            options.enableWatchdogTerminationTracking = false
            options.attachStacktrace = false
            options.enablePersistingTracesWhenCrashing = true

            // Configure App Hang
            options.enableAppHangTracking = false

            // Configure File I/O
            options.enableFileIOTracing = false
            options.enableDataSwizzling = false
            options.enableFileManagerSwizzling = false

            // Configure Tracing
            options.enableAutoPerformanceTracing = false
            options.enableCoreDataTracing = false

            // Configure Networking
            options.enableNetworkTracking = false
            options.enableNetworkBreadcrumbs = false
            options.enableGraphQLOperationTracking = false
            options.enableCaptureFailedRequests = false

            // Configure Metrics
            options.enableMetrics = true

            // Configure Logs
            options.enableLogs = true

            // Configure Other Options
            options.experimental.enableUnhandledCPPExceptionsV2 = false
        }

        // Start collecting metrics when the app launches
        metricsCollector.start(hostname: customDeviceName.isEmpty ? nil : customDeviceName)

        SentrySDK.logger.info("App initialized")
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
