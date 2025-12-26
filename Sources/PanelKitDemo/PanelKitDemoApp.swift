//
//  PanelKitDemoApp.swift
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
import PanelKit

@main
struct PanelKitDemoApp: App {
    
    @State private var panel: PanelController<ImmersiveStyle>?
    
    init() {
        WallpaperService.shared.start()
        
        let content = ContentView()
        let controller = PanelController(
            style: ImmersiveStyle(),
            content: AnyView(content)
        )
        _panel = State(initialValue: controller)
    }
    
    var body: some Scene {
        WindowGroup {
            DemoView(presentPanel: presentPanel)
                .frame(width: 200, height: 300)
        }
    }
    
    func presentPanel() {
        panel?.present()
    }
}

struct DemoView: View {
    let presentPanel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("PanelKit ImmersiveStyle Demo")
                .font(.headline)
            
            Button("Present Panel") {
                presentPanel()
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


struct ContentView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.white)
            .frame(width: 320, height: 320)
            .shadow(color: .black.opacity(0.2), radius: 30, y: 15)
            .padding(80)
    }
}
