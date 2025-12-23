import AppKit
import SwiftUI
import VisualEffectView

@MainActor
public class FullScreenPanelController {
    private var fullScreenPanel: FullScreenPanel?
    private var escapeEventMonitor: Any?
    private var isVisible: Bool = false
    
    public init<V: View>(
        @ViewBuilder content: (FullScreenPanelController) -> V
    ) {
        let rootView = content(self)
        
        self.fullScreenPanel = FullScreenPanel(
            rootView: Self
                .styledRootView(
                    rootView,
                    for: self
                )
        )
    }
    
    public convenience init<V: View>(
        rootView: V,
    ) {
        self.init(
            content: { _ in rootView }
        )
    }
    
    public func showPanel() {
        guard !isVisible else { return }
        guard let panel = fullScreenPanel else { return }
        
        panel.alphaValue = 0.0
        panel.positionPanel()
        
        panel.orderFront(nil)
        
        DispatchQueue.main.async {
            panel.makeKey()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if !panel.isKeyWindow {
                    panel.makeKey()
                }
            }
        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.6
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1.0
        }
        
        addEscapeEventMonitor()
        
        NotificationCenter.default.post(name: .panelDidShow, object: nil)
        
        isVisible = true
    }
    
    public func hidePanel() {
        guard isVisible else { return }
        guard let panel = fullScreenPanel else { return }
        
        isVisible = false
        
        removeEscapeEventMonitor()
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0.0
        } completionHandler: {
            panel.close()
            
            panel.alphaValue = 1.0
            
            NotificationCenter.default.post(name: .panelDidHide, object: nil)
        }
    }
    
    public func togglePanel() {
        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    public func updateContentView<V: View>(
        _ rootView: V,
        visualEffect: VisualEffectConfiguration? = nil
    ) {
        fullScreenPanel?.updateContentView(
            Self.styledRootView(
                rootView, for: self,
            )
        )
    }
    
    public func isPanelVisible() -> Bool {
        return isVisible
    }
    
    private func addEscapeEventMonitor() {
        guard escapeEventMonitor == nil else { return }
        
        escapeEventMonitor = NSEvent
            .addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.keyCode == 53 {
                    Task { @MainActor in
                        self?.hidePanel()
                    }
                    return nil
                }
                return event
            }
    }
    
    private func removeEscapeEventMonitor() {
        if let monitor = escapeEventMonitor {
            NSEvent.removeMonitor(monitor)
            escapeEventMonitor = nil
        }
    }
    
    deinit { }
    
    private static func styledRootView<V: View>(
        _ rootView: V,
        for controller: FullScreenPanelController,
    ) -> AnyView {
        let wallpaperImage: NSImage? = {
            guard let screen = NSScreen.main,
                  let url = NSWorkspace.shared.desktopImageURL(for: screen) else {
                return nil
            }
            return NSImage(contentsOf: url)
        }()
        
        return AnyView(
            rootView
                .environment(\.panelController, controller)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        Rectangle().fill(Color.black)
                        
                        if let nsImage = wallpaperImage {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea()
                        }
                        
                        VisualEffectView(material: .fullScreenUI, blendingMode: .withinWindow)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                controller.hidePanel()
                            }
                    }
                )
                .ignoresSafeArea()
        )
    }
}

public struct FullScreenPanelControllerKey: EnvironmentKey {
    public static let defaultValue: FullScreenPanelController? = nil
}

public extension EnvironmentValues {
    var panelController: FullScreenPanelController? {
        get { self[FullScreenPanelControllerKey.self] }
        set { self[FullScreenPanelControllerKey.self] = newValue }
    }
}

public extension Notification.Name {
    static let panelDidShow = Notification.Name("panelDidShow")
    static let panelDidHide = Notification.Name("panelDidHide")
}
