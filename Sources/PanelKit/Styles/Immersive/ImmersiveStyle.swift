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
    
    public init() {}
    
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
        ImmersiveStylePanelView(content: content, state: state)
    }
}

/// The visual container for the ImmersiveStyle (Modern Implementation).
private struct ImmersiveStylePanelView: View {
    private let content: AnyView
    private let state: PanelState
    
    @Environment(\.panelActions) var actions

    @ObservedObject var store = WallpaperService.shared.store
    
    @State private var wallpaperURL: URL?
    
    init(content: AnyView, state: PanelState) {
            self.content = content
            self.state = state
        }
    
    var body: some View {
        ZStack {
            // 1. Panel Background
            Group {
                if let url = wallpaperURL, let wallpaper = store.wallpapers[url] {
                    Image(nsImage: wallpaper)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                }
                
                VisualEffectView(material: .fullScreenUI)
            }
            .onTapGesture {
                actions?.dismiss()
            }
            
            // 2. Content
            content
                .scaleEffect(contentScale)
                .animation(.easeOut(duration: 0.9), value: state)
                .allowsHitTesting(state == .presented)
                .onTapGesture { /* block dismiss when tapping content */ }
        }
        .task {
            // the wallpaper never changes while the panel is displayed
            if let screen = NSScreen.main {
                self.wallpaperURL = NSWorkspace.shared.desktopImageURL(for: screen)
            }
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
