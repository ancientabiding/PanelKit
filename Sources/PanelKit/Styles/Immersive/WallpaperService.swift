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
@available(macOS 14.0, *)
@MainActor
public final class WallpaperService {
    
    /// The singleton instance.
    public static let shared = WallpaperService()
    
    public let store = WallpaperStore()
    
    /// The maximum width (in pixels) for the cached wallpaper.
    private let targetWidth: CGFloat = 480
    
    private var observers: Set<AnyCancellable> = []
    
    /// Cache to store processed images in memory.
    /// Key: NSURL (Uniquely identifies the wallpaper file, handling Spaces correctly).
    private let cache = NSCache<NSURL, NSImage>()
    
    private init() {
        // Limit the cache to hold only this maximum images at same time.
        cache.countLimit = 6
    }
    
    public func start() {
        guard observers.isEmpty else { return } // Evita duplicidade
        
        setupObservers()
        refreshAllScreens() // Warmup inicial
    }
    
    /// Força uma atualização (útil se o app voltar de suspensão).
    public func refresh() {
        refreshAllScreens()
    }
    
    // MARK: - Monitoring Logic
    
    private func setupObservers() {
        let center = NSWorkspace.shared.notificationCenter
        let notificationCenter = NotificationCenter.default
        
        // A. Mudança de Space (Desktop Virtual)
        center.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)
        
        // B. Mudança do Arquivo de Wallpaper (Configurações do Sistema)
        // Usamos o nome cru (Raw Value) para contornar o erro de compilação da constante estática
        center.publisher(for: Notification.Name("NSWorkspaceDesktopImageDidChangeNotification"))
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)
        
        // C. Mudança de Telas (Resolução, Monitor Externo)
        notificationCenter.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in self?.refreshAllScreens() }
            .store(in: &observers)
    }
    
    // MARK: - Fetching & Processing
    
    /// Itera sobre todas as telas ativas e garante que seus wallpapers estejam no Store.
    private func refreshAllScreens() {
        for screen in NSScreen.screens {
            // Passo 1: Descobrir qual a URL que o sistema diz ser a atual
            guard let url = NSWorkspace.shared.desktopImageURL(for: screen) else { continue }
            
            // Passo 2 (O SEU FILTRO INTELIGENTE):
            // Se já temos essa URL processada no Store, ignoramos o gatilho.
            // Isso responde à sua pergunta: aqui nós "observamos" se a URL mudou de fato.
            if store.wallpapers[url] != nil { continue }
            
            // Passo 3: Se é nova, processamos em background
            Task {
                if let image = await processWallpaper(from: url) {
                    self.store.wallpapers[url] = image
                }
            }
        }
    }
    
    /// Processa a imagem em background usando ImageIO.
    private func processWallpaper(from url: URL) async -> NSImage? {
        let key = url as NSURL
        
        // Check Cache de Memória (caso tenha sido removido do Store mas ainda esteja no NSCache)
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        let width = targetWidth
        
        // FASE BACKGROUND (Thread Safe):
        // Retornamos CGImage (que é Sendable), evitando o erro de passar NSImage entre threads
        let cgImage = await Task.detached(priority: .userInitiated) {
            return Self.createThumbnailCG(from: url, maxPixelSize: width)
        }.value
        
        guard let cgImage else { return nil }
        
        // FASE MAIN ACTOR:
        // Convertemos para NSImage na thread principal
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
