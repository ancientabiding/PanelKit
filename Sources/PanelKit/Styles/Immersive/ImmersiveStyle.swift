//
//  ImmersiveStyle.swift
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
import AppKit
import VisualEffectKit

/// A panel style that mimics the macOS Launchpad experience.
///
/// Features:
/// - Full-screen coverage.
/// - Blurred wallpaper background.
/// - Fade-in/out animations.
/// - Borderless and immersive.
public struct ImmersiveStyle: PanelStyle {
    
    private let imageController: ImageController
    
    public init(backgroundImage: NSImage? = nil) {
        self.imageController = ImageController(initialImage: backgroundImage)
    }
    
    public func updateBackgroundImage(to image: NSImage?) {
        imageController.update(to: image)
    }
    
    public var configuration: PanelConfiguration {
        PanelConfiguration(
            level: .screenSaver, // Covers Dock and Menu Bar, All
            collectionBehavior: [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary],
            styleMask: [.fullSizeContentView, .nonactivatingPanel],
            isOpaque: false,
            hasShadow: false,
            backgroundColor: .clear,
            hidesOnDeactivate: false,
            titleVisibility: .hidden,
            titlebarAppearsTransparent: true,
            canBecomeKey: true,
            becomesKeyOnlyIfNeeded: false
        )
    }
    
    public var sizing: PanelSizing {
        .fullScreen
    }
    
    public var position: PanelPosition {
        .ignore
    }
    
    public var presentation: PanelPresentation {
        PanelPresentation(
            hiddenState: { panel in
                panel.alphaValue = 0
            },
            visibleState: { panel in
                panel.alphaValue = 1
            },
            enterTiming: PanelPresentationTiming(duration: 0.3, curve: .easeInEaseOut),
            exitTiming: PanelPresentationTiming(duration: 0.3, curve: .easeInEaseOut)
        )
    }
    
    public func panelView(content: AnyView, state: PanelState) -> some View {
        ImmersiveStylePanelView(content: content, imageController: imageController, state: state)
    }
}

private struct ImmersiveStylePanelView: View {
    let content: AnyView
    @ObservedObject var imageController: ImageController
    let state: PanelState
    
    @Environment(\.panelActions) var actions
    
    var body: some View {
        ZStack {
            // 1. Panel Background
            Group {
                if let nsImage = imageController.currentImage {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity.animation(.easeOut))
                }
                
                VisualEffectView(material: .fullScreenUI, blendingMode: .withinWindow)
            }
            .onTapGesture {
                actions?.dismiss()
            }
            
            // 2. Content
            content
                .scaleEffect(contentScale)
                .animation(.easeOut(duration: 0.9), value: state)
                .allowsHitTesting(state == .presented)
                .contentShape(Rectangle())
                .onTapGesture { } // Consumes tap to prevent propagation
        }
    }
    
    private var contentScale: CGFloat {
        switch state {
        case .hidden, .dismissing:
            return 1.1
        case .presented, .appearing:
            return 1.0
        }
    }
}

/// Gerencia o armazenamento e atualização da imagem de fundo.
@MainActor
public class ImageController: ObservableObject {
    /// A imagem atual em cache (memória).
    @Published public private(set) var currentImage: NSImage?
    
    public init(initialImage: NSImage? = nil) {
        self.currentImage = initialImage
    }
    
    /// Atualiza a imagem de fundo. Isso notificará automaticamente o painel para redesenhar.
    /// - Parameter image: A nova imagem a ser exibida ou nil para remover.
    public func update(to image: NSImage?) {
        // Evita atualizações desnecessárias se for a mesma referência
        guard image !== currentImage else { return }
        
        withAnimation(.easeOut(duration: 0.3)) {
            self.currentImage = image
        }
    }
    
    /// Limpa o cache da imagem explicitamente.
    public func clear() {
        self.update(to: nil)
    }
}
