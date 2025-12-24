//
//  PanelSizing.swift
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

import Foundation

/// Defines the strategy for sizing the panel window.
public enum PanelSizing: Sendable, Equatable {
    
    /// The panel ignores the content size and occupies the entire screen frame.
    case fullScreen
    
    /// The panel resizes itself to fit the SwiftUI content size.
    ///
    /// The controller will observe the content's `intrinsicContentSize` and animate the window frame.
    /// - Parameters:
    ///   - maxWidth: Optional maximum width constraint. If nil, width is unconstrained (up to screen width).
    ///   - maxHeight: Optional maximum height constraint. If nil, height is unconstrained (up to screen height).
    case adapting(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil)
    
    /// The panel has a fixed, static size that never changes, regardless of content.
    /// - Parameter size: The explicit size for the window.
    case fixed(size: CGSize)
}
