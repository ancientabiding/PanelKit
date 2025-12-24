//
//  PanelState.swift
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

import Foundation

/// Represents the lifecycle state of the panel window.
///
/// This state machine drives both the window visibility (managed by AppKit)
/// and the content animations (managed by SwiftUI).
public enum PanelState: Equatable, Sendable {
    
    /// The panel is fully closed and hidden from the screen.
    case hidden
    
    /// The panel is currently animating its entry.
    case appearing
    
    /// The panel is fully visible, stable, and interactive.
    case presented
    
    /// The panel is currently animating its exit.
    case dismissing
    
    // MARK: - Helpers
    
    /// Indicates if the panel is physically visible on screen (including animation states).
    public var isVisible: Bool {
        self != .hidden
    }
    
    /// Indicates if the panel is considered "open" or opening.
    /// Useful for determining toggle logic (if open, then close).
    public var isOpen: Bool {
        switch self {
        case .appearing, .presented:
            return true
        case .hidden, .dismissing:
            return false
        }
    }
    
    /// Indicates if the panel is in a transitional animation state.
    public var isAnimating: Bool {
        switch self {
        case .appearing, .dismissing:
            return true
        default:
            return false
        }
    }
}
