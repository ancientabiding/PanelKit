//
//  WallpaperStore.swift
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
import Observation

@available(macOS 14.0, *)
@Observable
public final class WallpaperStore {
    public var wallpapers: [URL: NSImage] = [:]
    
    public init() {}
    
    public func wallpaper(for url: URL?) -> NSImage? {
        guard let url else { return nil }
        return wallpapers[url]
    }
}
