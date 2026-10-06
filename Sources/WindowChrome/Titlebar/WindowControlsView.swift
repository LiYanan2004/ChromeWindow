import AppKit
import SwiftUI

struct WindowControlsView: NSViewRepresentable {
    func makeNSView(context: Context) -> TitlebarContainerView {
        TitlebarContainerView(frame: .zero)
    }

    func updateNSView(_ containerView: TitlebarContainerView, context: Context) {}
}
