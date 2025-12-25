//
//  PanelBridge.swift
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

import SwiftUI
import Combine

/// Encapsulates the interaction between AppKit and SwiftUI.
/// Responsible for hosting the view, managing reactive state, and reporting content size.
@MainActor
final class PanelBridge<Style: PanelStyle> {
        
    /// The backing ObservableObject that drives SwiftUI updates.
    private let stateBridge = StateBridge()
    
    /// The AppKit view controller hosting the SwiftUI content.
    let sizingBridge: NSHostingController<BridgeView<Style>>
        
    init(content: AnyView, style: Style, actions: PanelActions?) {
        let bridgeView = BridgeView(
            content: content,
            style: style,
            actions: actions,
            stateBridge: stateBridge
        )
        
        self.sizingBridge = NSHostingController(rootView: bridgeView)
    }
        
    /// Updates the reactive state, triggering SwiftUI animations if needed.
    func updateState(to newState: PanelState) {
        stateBridge.state = newState
    }
    
    /// Retrieves the current reactive state.
    var currentState: PanelState {
        stateBridge.state
    }
    
    /// Calculates the size required to fit the SwiftUI content.
    var fittingSize: CGSize {
        sizingBridge.view.fittingSize
    }
}

/// Private observable source of truth.
@MainActor
final class StateBridge: ObservableObject {
    @Published var state: PanelState = .hidden
}

/// The wrapper view that injects state into the Style.
struct BridgeView<Style: PanelStyle>: View {
    let content: AnyView
    let style: Style
    let actions: PanelActions?
    @ObservedObject var stateBridge: StateBridge
    
    var body: some View {
        style.panelView(content: content, state: stateBridge.state)
            .environment(\.panelActions, actions)
    }
}
