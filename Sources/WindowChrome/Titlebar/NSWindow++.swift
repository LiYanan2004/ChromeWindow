import AppKit

extension NSWindow {
    func configureTitlebar() {
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        titlebarSeparatorStyle = .none
        toolbarStyle = .unifiedCompact

        // sub_52460 preserves a titled window and hides its titlebar drawing.
        styleMask.insert(NSWindow.StyleMask(rawValue: 1 << 32))
        _setTitlebarAlphaValue(0)
    }
    
    private func _setTitlebarAlphaValue(_ alpha: CGFloat) {
        let selector = NSSelectorFromString("setTitlebarAlphaValue:")
        guard responds(to: selector), let implementation = method(for: selector) else { return }
        typealias TitlebarAlphaSetter = @convention(c) (AnyObject, Selector, CGFloat) -> Void
        let setter = unsafeBitCast(implementation, to: TitlebarAlphaSetter.self)
        setter(self, selector, alpha)
    }
}
