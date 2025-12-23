import AppKit
import SwiftUI

@MainActor
public class FullScreenPanel: NSPanel {
    
    public init<V: View>(rootView: V) {
        let screenFrame = NSScreen.main?.frame ?? .zero
        
        super.init(
            contentRect: screenFrame,
            styleMask: [.fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        configurePanel()
        addContentView(rootView: rootView)
        positionPanel()
    }
    
    private func configurePanel() {
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = .screenSaver
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        
        becomesKeyOnlyIfNeeded = false
        
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
    }
    
    override public var canBecomeKey: Bool {
        return true
    }

    override public func makeKey() {
        super.makeKey()
    }
    
    private func addContentView<V: View>(rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
    
    public func positionPanel() {
        // Garante que o painel ocupe a tela atual
        if let screen = NSScreen.main {
            setFrame(screen.frame, display: true)
        }
    }
    
    public func updateContentView<V: View>(_ rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
}
