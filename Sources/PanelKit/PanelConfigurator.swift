//
//  PanelConfigurator.swift
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

/// A closure that configures properties on an NSPanel instance.
public typealias PanelConfigurator = @MainActor @Sendable (NSPanel) -> Void
