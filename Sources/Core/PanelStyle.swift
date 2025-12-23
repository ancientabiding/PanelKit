//
//  PanelStyle.swift
//  FullScreenPanel
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

/// The blueprint for a panel's appearance and behavior.
///
/// Implement this protocol to create custom panel presets.
/// The controller uses this protocol to delegate configuration, layout, visual composition, and animation definitions.
@MainActor
public protocol PanelStyle: Sendable {
    
    /// Configuration for the underlying `NSPanel` (level, shadow, behavior).
    var configuration: PanelConfiguration { get }
    
    /// Strategy for sizing the window (Fullscreen, Adapting).
    var layout: PanelLayout { get }
    
    /// Strategy for positioning the window on screen (Center, Top, Bottom).
    var position: PanelPosition { get }
    
    /// Defines how the panel is presented and dismissed (visuals and timing).
    var presentation: PanelPresentation { get }
    
    /// The type of View representing the panel's body.
    associatedtype Body: View
    
    /// Constructs the visual hierarchy of the panel.
    ///
    /// Use this method to wrap the user's content with backgrounds, effects, or layout logic.
    /// - Parameters:
    ///   - content: The type-erased user content to be displayed.
    ///   - state: The current lifecycle state of the panel.
    /// - Returns: A fully configured SwiftUI View.
    @ViewBuilder
    func body(content: AnyView, state: PanelState) -> Body
}
