import AppKit
import SwiftUI

struct WindowControlsView: NSViewRepresentable {
    let toolbarContent: AnyView?

    func makeNSView(context: Context) -> TitlebarContainerView {
        let containerView = TitlebarContainerView(frame: .zero)
        containerView.updateToolbarContent(toolbarContent)
        return containerView
    }

    func updateNSView(_ containerView: TitlebarContainerView, context: Context) {
        containerView.updateToolbarContent(toolbarContent)
    }
}
