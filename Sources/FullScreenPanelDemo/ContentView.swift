import SwiftUI
import FullScreenPanel

struct ContentView: View {
    @Environment(\.panelController) private var panelController

    var body: some View {
        VStack {
            Rectangle().fill(Color.white).frame(width: 300, height: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
