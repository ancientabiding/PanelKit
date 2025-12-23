import AppKit
import SwiftUI
import FullScreenPanel

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: FullScreenPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        panelController = FullScreenPanelController { _ in
            ContentView()
        }
        
        panelController?.showPanel()
    }
}

