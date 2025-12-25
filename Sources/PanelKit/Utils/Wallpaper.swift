//
//  Wallpaper.swift
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

import AppKit
import ImageIO

/// A thread-safe utility to fetch and cache desktop wallpapers efficiently.
/// optimized for performance using ImageIO downsampling and memory constraints.
@MainActor
final class Wallpaper {
    
    /// The singleton instance.
    static let shared = Wallpaper()
        
    /// The maximum width (in pixels) for the cached wallpaper.
    private let targetWidth: CGFloat = 720
        
    /// Cache to store processed images in memory.
    /// Key: NSURL (Uniquely identifies the wallpaper file, handling Spaces correctly).
    private let cache = NSCache<NSURL, NSImage>()
    
    private init() {
        // Limit the cache to hold only this maximum images at same time.
        cache.countLimit = 4
    }
        
    /// Retrieves the wallpaper for the current active space on a specific screen asynchronously.
    /// - Parameter screen: The target screen (needed to query the active Space URL).
    /// - Returns: A downsampled NSImage ready for display, or nil if inaccessible.
    func get(for screen: NSScreen) async -> NSImage? {
        // 1. Get URL (Source of Truth for Spaces)
        // NSWorkspace correctly returns the URL for the currently visible Space on this screen.
        guard let url = NSWorkspace.shared.desktopImageURL(for: screen) else {
            return nil
        }
        
        let key = url as NSURL
        
        // 2. Check Cache (Fast Path)
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // 3. Load & Downsample (Performance Path)
        // Offload to background to avoid blocking Main Thread
        let maxPixelSize = targetWidth
        
        let result = await Task.detached(priority: .userInitiated) {
            let image = Self.createThumbnail(from: url, maxPixelSize: maxPixelSize)
            return SendableImage(image)
        }.value
        
        if let image = result.image {
            cache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
    
    /// Manually clears the cache. Useful for memory warnings.
    func clearCache() {
        cache.removeAllObjects()
    }
        
    /// Reads an image from disk and decodes it directly into a smaller size.
    /// This avoids loading the full-resolution image into RAM.
    nonisolated private static func createThumbnail(from url: URL, maxPixelSize: CGFloat) -> NSImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true, // Respects EXIF orientation
            kCGImageSourceShouldCacheImmediately: true,       // Decodes immediately (avoids UI hitch later)
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        
        // Create the low-level image source without reading data yet
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        // create the thumbnail (Hardware accelerated decoding)
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        // Convert back to AppKit object
        return NSImage(cgImage: cgImage, size: NSSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)))
    }
}

/// Helper to safely transfer NSImage across concurrency domains
private struct SendableImage: @unchecked Sendable {
    let image: NSImage?
    init(_ image: NSImage?) { self.image = image }
}
