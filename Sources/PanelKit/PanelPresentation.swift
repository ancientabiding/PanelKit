//
//  PanelPresentation.swift
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
import QuartzCore

/// Defines the duration and timing curve for an animation.
public struct PanelPresentationTiming: Sendable {
    public let duration: TimeInterval
    public let curve: CAMediaTimingFunctionName
    
    public init(duration: TimeInterval, curve: CAMediaTimingFunctionName) {
        self.duration = duration
        self.curve = curve
    }
}

/// Defines Hidden and Visible states and the transition between them.
public struct PanelPresentation: Sendable {
        
    /// Configures the panel Hidden state.
    public let hiddenState: PanelConfigurator
    
    /// Configures the panel Visible state.
    public let visibleState: PanelConfigurator
    
    /// Timing configuration for the Appear animation (Hidden -> Visible).
    public let enterTiming: PanelPresentationTiming
    
    /// Timing configuration for the Dismiss animation (Visible -> Hidden).
    public let exitTiming: PanelPresentationTiming

    public init(
        hiddenState: @escaping PanelConfigurator,
        visibleState: @escaping PanelConfigurator,
        enterTiming: PanelPresentationTiming,
        exitTiming: PanelPresentationTiming
    ) {
        self.hiddenState = hiddenState
        self.visibleState = visibleState
        self.enterTiming = enterTiming
        self.exitTiming = exitTiming
    }
}
