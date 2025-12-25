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
import Combine

/// A reactive store for desktop wallpapers compatible with macOS 12+.
/// Uses `ObservableObject` to ensure compatibility across older and newer systems.
public final class WallpaperStore: ObservableObject {
    
    @Published public private(set) var wallpapers: [URL: NSImage] = [:]
    
    private var keyOrder: [URL] = []
    
    private let capacity = 6
    
    public init() {}
    
    public func image(for url: URL?) -> NSImage? {
        guard let url else { return nil }
        return wallpapers[url]
    }
    
    @MainActor
    public func update(_ image: NSImage, for url: URL) {
        wallpapers[url] = image
        
        if let index = keyOrder.firstIndex(of: url) {
            keyOrder.remove(at: index)
        }
        keyOrder.append(url)
        
        while keyOrder.count > capacity {
            let keyToRemove = keyOrder.removeFirst()
            if keyToRemove != url {
                wallpapers.removeValue(forKey: keyToRemove)
            }
        }
    }
}
