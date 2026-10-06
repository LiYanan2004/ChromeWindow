import AppKit
import SwiftUI

@MainActor
final class WindowToolbarHostingView: NSHostingView<WindowToolbarItems> {
    // ScreenContinuityUI.ToolBarHostingView.safeAreaInsets, sub_328ec.
    override var safeAreaInsets: NSEdgeInsets { NSEdgeInsetsZero }
}
