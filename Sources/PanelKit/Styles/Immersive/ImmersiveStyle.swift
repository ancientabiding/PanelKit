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
            level: .screenSaver, // Covers Dock and Menu Bar
            collectionBehavior: [.canJoinAllSpaces, .fullScreenAuxiliary],
            styleMask: [.borderless, .nonactivatingPanel],
            isOpaque: false,
            hasShadow: false,
            backgroundColor: .clear,
            hidesOnDeactivate: false,
            canBecomeKey: true
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
        if #available(macOS 14.0, *) {
            ImmersiveStylePanelView(content: content, state: state)
        } else {
            // Fallback on earlier versions
        }
    }
}

/// The visual container for the ImmersiveStyle.
@available(macOS 14.0, *)
private struct ImmersiveStylePanelView: View {
    private let content: AnyView
    private let state: PanelState
    
    @Environment(\.panelActions) var actions
    
    private var store = WallpaperService.shared.store
    
    @State private var wallpaperURL: URL?
    
    init(content: AnyView, state: PanelState) {
            self.content = content
            self.state = state
        }
    
    var body: some View {
        ZStack {
            // 1. Background Layer
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
            
            // 2. Content Layer
            content
                .scaleEffect(contentScale)
                .animation(.easeOut(duration: 0.9), value: state)
                .allowsHitTesting(state == .presented)
                .onTapGesture { /* block dismiss when tapping content */ }
        }
        .task {
            if let screen = NSScreen.main {
                self.wallpaperURL = NSWorkspace.shared.desktopImageURL(for: screen)
            }
        }
    }
    
    private var contentScale: CGFloat {
        // Subtle zoom effect: Start slightly larger (1.1) and zoom in to 1.0
        switch state {
        case .hidden: return 1.1
        case .appearing: return 1.0
        case .presented: return 1.0
        case .dismissing: return 1.1
        }
    }
}
