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

@available(macOS 13.0, *)
@main
struct PanelKitDemoApp: App {
    
    // 1. Inicialização Global
    init() {
        // Iniciamos o serviço de Wallpaper assim que o app abre.
        // Isso garante que o cache de imagem esteja "quente" (warm)
        // quando o usuário clicar no botão, evitando lags na primeira abertura.
        if #available(macOS 14.0, *) {
            WallpaperService.shared.start()
        }
    }

    var body: some Scene {
        WindowGroup {
            DemoControlView()
                .frame(width: 300, height: 200)
        }
        .windowResizability(.contentSize)
    }
}

// MARK: - A Janela Principal (Controle)

struct DemoControlView: View {
    /// Mantemos o controller vivo na memória associado a esta View.
    /// O Generic <ImmersiveStyle> define o comportamento do painel.
    @State private var panel: PanelController<ImmersiveStyle>?

    var body: some View {
        VStack(spacing: 20) {
            if #available(macOS 14.0, *) {
                Image(systemName: "macwindow.on.rectangle")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                    .symbolEffect(.bounce, value: panel != nil)
            } else {
                // Fallback on earlier versions
            }
            
            Text("PanelKit Demo")
                .font(.headline)
            
            Button("Open Immersive Panel") {
                presentPanel()
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .keyboardShortcut("k", modifiers: [.command]) // Cmd+K para abrir
        }
        .padding()
    }

    private func presentPanel() {
        // Singleton/Lazy Pattern:
        // Só criamos o painel se ele ainda não existir.
        if panel == nil {
            // Conteúdo que será exibido DENTRO do painel
            let content = ImmersivePayloadView()
            
            // Instanciamos o Controller
            panel = PanelController(
                style: ImmersiveStyle(),
                content: AnyView(content)
            )
        }
        
        // Comanda a abertura
        panel?.present()
    }
}

// MARK: - O Conteúdo do Painel (Payload)

/// Esta é a view que aparecerá flutuando sobre o wallpaper borrado.
struct ImmersivePayloadView: View {
    // Acessamos a action injetada pelo PanelController para fechar programmaticamente
    @Environment(\.panelActions) var panelActions
    
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 40) {
            // 1. Título
            Text("Good Evening")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            
            // 2. Search Bar Simulada
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                TextField("Search for apps, files or commands...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.title2)
            }
            .padding(20)
            .background(.ultraThinMaterial) // Vidro nativo do macOS
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .frame(maxWidth: 600)
            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            
            // 3. Grid de Ícones (Mock)
            HStack(spacing: 40) {
                MockIcon(icon: "safari.fill", color: .blue, name: "Safari")
                MockIcon(icon: "message.fill", color: .green, name: "Messages")
                MockIcon(icon: "music.note", color: .pink, name: "Music")
                MockIcon(icon: "folder.fill", color: .cyan, name: "Finder")
            }
            
            // 4. Botão de Fechar Explicito
            // (Lembrando que o ImmersiveStyle também fecha clicando no fundo)
            Button("Dismiss") {
                panelActions?.dismiss()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.white)
            .padding(.top, 50)
        }
        .padding()
    }
}

// Componente visual apenas para o Demo
struct MockIcon: View {
    let icon: String
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            
            Text(name)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(radius: 2)
        }
        .onTapGesture {
            // Simula clique num app
            print("Launched \(name)")
        }
    }
}
