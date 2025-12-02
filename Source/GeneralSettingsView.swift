import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(AppStorageKeys.Settings.customDeviceName) private var customDeviceName = ""
    @AppStorage(AppStorageKeys.Settings.customSentryDSN) private var customSentryDSN = ""

    var body: some View {
        Form {
            Section {
                TextField("settings.general.custom-device-name.title", text: $customDeviceName)
            } footer: {
                Text("settings.general.custom-device-name.info")
            }

            Section {
                TextField("settings.general.custom-sentry-dsn.title", text: $customSentryDSN)
            } footer: {
                Text("settings.general.custom-sentry-dsn.info")
            }
        }
        .formStyle(.grouped)
    }
}
