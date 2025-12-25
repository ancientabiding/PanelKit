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
    
    // 1. Tornamos a escrita privada para forçar o uso do método 'update'
    public private(set) var wallpapers: [URL: NSImage] = [:]
    
    // 2. Lista auxiliar para rastrear a ordem de uso (LRU)
    private var keyOrder: [URL] = []
    
    // 3. Limite sincronizado com o do Service (ou um pouco maior)
    private let capacity = 6
    
    public init() {}
    
    public func wallpaper(for url: URL?) -> NSImage? {
        guard let url else { return nil }
        return wallpapers[url]
    }
    
    /// Adiciona ou atualiza uma imagem, garantindo que o limite de memória seja respeitado.
    @MainActor
    public func update(_ image: NSImage, for url: URL) {
        // A. Adiciona ao dicionário
        wallpapers[url] = image
        
        // B. Atualiza a lista de "Mais Recentes"
        // Se já existia, remove da posição antiga para mover para o fim da fila
        if let index = keyOrder.firstIndex(of: url) {
            keyOrder.remove(at: index)
        }
        keyOrder.append(url)
        
        // C. Pruning (Poda)
        // Se passou do limite, remove o mais antigo (o primeiro da fila)
        while keyOrder.count > capacity {
            let keyToRemove = keyOrder.removeFirst()
            // Segurança: não remova a imagem que acabamos de adicionar
            if keyToRemove != url {
                wallpapers.removeValue(forKey: keyToRemove)
            }
        }
    }
}
