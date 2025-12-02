import SFSafeSymbols
import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("settings.general.title", systemImage: SFSymbol.gear.rawValue) {
                GeneralSettingsView()
            }
        }
        .scenePadding()
        .frame(maxWidth: 550)
    }
}
