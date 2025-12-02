import AppKit
import SFSafeSymbols
import SwiftUI

struct MenuContentView: View {
    var body: some View {
        VStack {
            SettingsLink {
                Label("menu.settings.title", systemSymbol: .gear)
            }
            Divider()
            Button {
                NSWorkspace.shared.open(Globals.helpUrl)
            } label: {
                Label("menu.help.title", systemSymbol: .questionmarkCircleFill)
            }
            Button {
                NSApp.orderFrontStandardAboutPanel(nil)
            } label: {
                Label("menu.about.title", systemSymbol: .infoCircleFill)
            }
            Divider()
            Button {
                NSApp.terminate(nil)
            } label: {
                Label("menu.quit.title", systemSymbol: .xmarkCircleFill)
            }
        }
        .padding()
    }
}
