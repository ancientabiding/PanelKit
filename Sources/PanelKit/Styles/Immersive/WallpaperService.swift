//
//  WallpaperService.swift
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
import Combine

/// A thread-safe utility to fetch and cache desktop wallpapers efficiently.
/// optimized for performance using ImageIO downsampling and memory constraints.
/// Compatible with macOS 12+.
@MainActor
public final class WallpaperService {
    
    public static let shared = WallpaperService()
    
    public let store = WallpaperStore()
    
    private let targetWidth: CGFloat = 480
    
    private var observers: Set<AnyCancellable> = []
    
    private var processingURLs: Set<URL> = []
    
    private let cache = NSCache<NSURL, NSImage>()
    
    private init() {
        cache.countLimit = 6
    }
    
    public func start() {
        guard observers.isEmpty else { return }
        
        setupObservers()
        refreshAllScreens()
    }
    
    public func refresh() {
        refreshAllScreens()
    }
    
    private func setupObservers() {
        let center = NSWorkspace.shared.notificationCenter
        let notificationCenter = NotificationCenter.default
        
        center.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)
        
        center.publisher(for: Notification.Name("NSWorkspaceDesktopImageDidChangeNotification"))
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)
        
        notificationCenter.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)
    }
    
    private func refreshAllScreens() {
        for screen in NSScreen.screens {
            guard let url = NSWorkspace.shared.desktopImageURL(for: screen) else { continue }
            
            if store.wallpapers[url] != nil || processingURLs.contains(url) { continue }
            processingURLs.insert(url)
            
            Task {
                if let image = await processWallpaper(from: url) {
                    self.store.update(image, for: url)
                }
                self.processingURLs.remove(url)
            }
        }
    }
    
    private func processWallpaper(from url: URL) async -> NSImage? {
        let key = url as NSURL
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        let width = targetWidth
        
        let cgImage = await Task.detached(priority: .userInitiated) {
            return Self.createThumbnailCG(from: url, maxPixelSize: width)
        }.value
        
        guard let cgImage else { return nil }
        
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)))
        
        cache.setObject(nsImage, forKey: key)
        return nsImage
    }
    
    nonisolated private static func createThumbnailCG(from url: URL, maxPixelSize: CGFloat) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    }
}
