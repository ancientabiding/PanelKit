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

// TODO: Think on a good monitoring for SandBoxed apps

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
    
    private var databaseMonitor: DispatchSourceFileSystemObject?
    
    private var databaseFileDescriptor: Int32 = -1
    
    private let cache = NSCache<NSURL, NSImage>()
    
    private init() {
        cache.countLimit = 6
    }
    
    public func start() {
        guard observers.isEmpty else { return }
        
        setupObservers()
        setupFileMonitor()
        refreshAllScreens()
    }
    
    public func refresh() {
        refreshAllScreens()
    }
    
    private func setupObservers() {
        let wsCenter = NSWorkspace.shared.notificationCenter
        let appCenter = NotificationCenter.default
        let distCenter = DistributedNotificationCenter.default()
        
        wsCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)
        
        appCenter.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)

        distCenter.addObserver(self, selector: #selector(handleDistributedChange), name: Notification.Name("com.apple.desktop.backgroundChanged"), object: nil)
    }
    
    @objc private func handleDistributedChange() {
        Task { @MainActor in self.refreshAllScreens() }
    }
    
    private func setupFileMonitor() {
        guard let libraryDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        
        let dockDir = libraryDir.appendingPathComponent("Dock")
        let dbPath = dockDir.appendingPathComponent("desktoppicture.db")
        
        guard FileManager.default.fileExists(atPath: dbPath.path) else { return }
        
        let fd = open(dbPath.path, O_EVTONLY)
        guard fd >= 0 else {
            print("PanelKit: Wallpaper DB monitoring disabled (Sandbox restriction). Using notifications fallback.")
            return
        }
        
        self.databaseFileDescriptor = fd
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .extend, .delete, .rename],
            queue: DispatchQueue.global(qos: .utility)
        )
        
        source.setEventHandler { [weak self] in
            Task { @MainActor in
                self?.refreshAllScreens()
            }
        }
        
        source.setCancelHandler {
            close(fd)
        }
        
        source.resume()
        self.databaseMonitor = source
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
