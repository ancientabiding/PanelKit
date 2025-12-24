//
//  Panel.swift
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

/// A custom NSPanel subclass that enables dynamic behavior configuration,
/// specifically overriding read-only properties like `canBecomeKey`.
public class Panel: NSPanel {
    
    /// Internal storage for the key-window capability.
    private var _canBecomeKey: Bool = false
    
    /// Overrides the system property to return our configured value.
    override public var canBecomeKey: Bool {
        return _canBecomeKey
    }
    
    /// Initializes the panel using the standard configuration.
    public init(configuration: PanelConfiguration) {
        super.init(
            contentRect: .zero,
            styleMask: configuration.styleMask,
            backing: .buffered,
            defer: false
        )

        self.level = configuration.level
        self.collectionBehavior = configuration.collectionBehavior
        self.isOpaque = configuration.isOpaque
        self.hasShadow = configuration.hasShadow
        self.backgroundColor = configuration.backgroundColor
        self.hidesOnDeactivate = configuration.hidesOnDeactivate
        self._canBecomeKey = configuration.canBecomeKey
        
        // Prevent automatic release when closed to allow reuse
        self.isReleasedWhenClosed = false
        // Prevent hiding via Cmd+H to maintain explicit lifecycle control
        self.canHide = false
    }
}
