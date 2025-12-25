//
//  PanelController.swift
//  PanelKit
//
//
//                     -(]-
//                      (\ _  ._~''
//           ,_  _,.--..( ,_.+  (`\
//     -~.__--=_/'(    ` ) /  (  `'   JG
//              ,_/ \ /'.__,. ).
//           `_/     `\_  ._/ ` \ ,
//                      `
//

import AppKit
import SwiftUI

/// The orchestrator that manages the system window (`NSPanel`) lifecycle and geometry.
@MainActor
public class PanelController<Style: PanelStyle> {
    
    /// The style blueprint defining behavior and appearance.
    public let style: Style
    
    /// The underlying system window.
    public let panel: Panel
    
    /// The bridge handling SwiftUI hosting and state.
    private let bridge: PanelBridge<Style>
    
    /// Read-only access to the current lifecycle state.
    public var state: PanelState {
        bridge.currentState
    }
    
    public init(style: Style, content: AnyView) {
        self.style = style
        
        // 1. Build the Window
        self.panel = Panel(configuration: style.configuration)
        
        // 2. Resolve "Self" Cycle
        let proxy = DismissalProxy()
        let actions = PanelActions(dismiss: {
            Task { @MainActor in
                proxy.perform()
            }
        })
        
        // 3. Build the Bridge
        // Passamos 'actions' diretamente para o construtor da bridge.
        // A bridge se encarrega de colocar o .environment no lugar certo (na BridgeView).
        self.bridge = PanelBridge(content: content, style: style, actions: actions)
        
        // 4. Connect layers
        self.panel.contentViewController = bridge.sizingBridge
        bridge.sizingBridge.view.autoresizingMask = [.width, .height]
        
        // 5. Finalize "Self"
        proxy.controller = self
        
        // 6. Initial Setup
        bridge.updateState(to: .hidden)
        style.presentation.hiddenState(panel)
        
        performLayout()
    }
    
    public func present() {
        guard !state.isOpen && !state.isAnimating else { return }
        
        performLayout()
        
        bridge.updateState(to: .appearing)
        
        panel.makeKeyAndOrderFront(nil)
        
        // 3. Run AppKit Animation (Entry)
        let timing = style.presentation.enterTiming
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = timing.duration
            context.timingFunction = CAMediaTimingFunction(name: timing.curve)
            
            // Execute the 'Visible' configurator within the animator proxy
            style.presentation.visibleState(panel.animator())
            
        } completionHandler: {
            // 4. Update State -> .presented
            self.bridge.updateState(to: .presented)
        }
    }
    
    public func dismiss() {
        guard state.isOpen && !state.isAnimating else { return }
        
        // 1. Update State -> .dismissing
        bridge.updateState(to: .dismissing)
        
        // 2. Run AppKit Animation (Exit)
        let timing = style.presentation.exitTiming
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = timing.duration
            context.timingFunction = CAMediaTimingFunction(name: timing.curve)
            
            // Execute the 'Hidden' configurator within the animator proxy
            style.presentation.hiddenState(panel.animator())
            
        } completionHandler: {
            // 3. Update State -> .hidden & Remove from screen
            self.panel.orderOut(nil)
            self.bridge.updateState(to: .hidden)
        }
    }
    
    private func performLayout() {
        guard let screen = NSScreen.main else {
            debugPrint("⚠️ PanelKit Error: Attempted to perform layout but NSScreen.main is nil.")
            assertionFailure("PanelKit: Layout calculation failed. NSScreen.main is required.")
            return
        }
        
        // 1. Determine Target Size
        var targetSize: CGSize
        
        switch style.sizing {
        case .fullScreen:
            targetSize = screen.frame.size
            
        case .fixed(let size):
            targetSize = size
            
        case .adapting(let maxWidth, let maxHeight):
            // Ask the Bridge for the SwiftUI content size
            let fittingSize = bridge.fittingSize
            
            let width = min(fittingSize.width, maxWidth ?? screen.frame.width)
            let height = min(fittingSize.height, maxHeight ?? screen.frame.height)
            
            // Ensure minimum viable size
            let minSize: CGFloat = 1.0
            targetSize = CGSize(
                width: max(width, minSize),
                height: max(height, minSize)
            )
        }
        
        // 2. Determine Origin (Position)
        var targetOrigin: CGPoint = .zero
        
        switch style.position {
        case .center:
            targetOrigin.x = screen.frame.midX - (targetSize.width / 2)
            targetOrigin.y = screen.frame.midY - (targetSize.height / 2)
            
        case .top(let offset):
            targetOrigin.x = screen.frame.midX - (targetSize.width / 2)
            // macOS coords: Bottom-Left is (0,0). Top is MaxY.
            targetOrigin.y = screen.frame.maxY - offset - targetSize.height
            
        case .bottom(let offset):
            targetOrigin.x = screen.frame.midX - (targetSize.width / 2)
            targetOrigin.y = screen.frame.minY + offset
            
        case .absolute(let point):
            targetOrigin = point
            
        case .ignore:
            targetOrigin = (style.sizing == .fullScreen) ? .zero : panel.frame.origin
        }
        
        // 3. Apply Frame
        let targetFrame = CGRect(origin: targetOrigin, size: targetSize)
        panel.setFrame(targetFrame, display: true)
    }
}

/// Helper class to break the initialization cycle between `self` and the closure capturing `self`.
@MainActor
private final class DismissalProxy {
    weak var controller: PanelActionsProvider?
    
    func perform() {
        controller?.dismiss()
    }
}

@MainActor
private protocol PanelActionsProvider: AnyObject {
    func dismiss()
}

extension PanelController: PanelActionsProvider {}


/// Small sandboxed API exposed to PanelStyles.
public struct PanelActions: Sendable {
    public let dismiss: @Sendable () -> Void
    
    public init(dismiss: @escaping @Sendable () -> Void) {
        self.dismiss = dismiss
    }
}

private struct PanelActionsKey: EnvironmentKey {
    static let defaultValue: PanelActions? = nil
}

extension EnvironmentValues {
    public var panelActions: PanelActions? {
        get { self[PanelActionsKey.self] }
        set { self[PanelActionsKey.self] = newValue }
    }
}
