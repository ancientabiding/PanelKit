//
//  PanelPosition.swift
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

/// Defines the strategy for positioning the panel window on the screen.
public enum PanelPosition: Sendable, Equatable {
    
    /// Centers the panel both horizontally and vertically on the screen.
    case center
    
    /// Centers the panel horizontally, aligned to the top of the screen with a vertical offset.
    /// - Parameter offset: The distance in points from the top edge of the screen to the top of the window.
    case top(offset: CGFloat)
    
    /// Centers the panel horizontally, aligned to the bottom of the screen with a vertical offset.
    /// - Parameter offset: The distance in points from the bottom edge of the screen to the bottom of the window.
    case bottom(offset: CGFloat)
    
    /// Positions the panel at a specific coordinate in screen space.
    /// Note: macOS uses a bottom-left coordinate system (0,0 is bottom-left).
    /// - Parameter point: The (x, y) origin for the window frame.
    case absolute(point: CGPoint)
    
    /// The controller will not attempt to set the window's position logic.
    /// This is the default for fullscreen layouts (where position is implicitly 0,0)
    /// or when you want to handle positioning manually.
    case ignore
}
