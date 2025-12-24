//
//  PanelConfiguration.swift
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

import AppKit

/// Defines the configuration for the underlying `NSPanel` window.
///
/// These properties control the window's behavior within the macOS windowing system,
/// such as z-index level, interactions with Spaces/Mission Control, and transparency.
public struct PanelConfiguration: Sendable {
    
    /// The window level.
    public var level: NSWindow.Level
    
    /// The collection behavior determining how the panel interacts with Mission Control and Spaces.
    public var collectionBehavior: NSWindow.CollectionBehavior
    
    /// The style mask defining the window's visual style and capabilities (e.g., borderless, resizable).
    public var styleMask: NSWindow.StyleMask
    
    /// Indicates if the window is opaque.
    public var isOpaque: Bool
    
    /// Indicates if the window has a standard macOS shadow.
    public var hasShadow: Bool
    
    /// The background color of the window itself.
    public var backgroundColor: NSColor
    
    /// Indicates if the panel should hide when the application loses focus.
    public var hidesOnDeactivate: Bool
    
    /// Indicates if the panel accepts keyboard focus even if it has a `.nonactivatingPanel` style mask.
    public var canBecomeKey: Bool
    
    public init(
        level: NSWindow.Level,
        collectionBehavior: NSWindow.CollectionBehavior,
        styleMask: NSWindow.StyleMask,
        isOpaque: Bool,
        hasShadow: Bool,
        backgroundColor: NSColor,
        hidesOnDeactivate: Bool,
        canBecomeKey: Bool
    ) {
        self.level = level
        self.collectionBehavior = collectionBehavior
        self.styleMask = styleMask
        self.isOpaque = isOpaque
        self.hasShadow = hasShadow
        self.backgroundColor = backgroundColor
        self.hidesOnDeactivate = hidesOnDeactivate
        self.canBecomeKey = canBecomeKey
    }
}
