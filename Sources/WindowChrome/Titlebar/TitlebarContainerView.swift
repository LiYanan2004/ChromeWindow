import AppKit
import SwiftUI

/// Hosts the window's original controls while AppKit keeps ownership of their behavior.
@MainActor
final class TitlebarContainerView: NSView {
    private var observations: [NSKeyValueObservation] = []
    private let toolbarItemHost = NSHostingView(rootView: EmptyView())

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        // sub_31f28: the empty demo toolbar uses the same hosting configuration.
        toolbarItemHost.sizingOptions = []
        let selector = NSSelectorFromString("_setSemanticContext:")
        if toolbarItemHost.responds(to: selector),
           let implementation = toolbarItemHost.method(for: selector) {
            typealias SemanticContextSetter = @convention(c) (AnyObject, Selector, Int) -> Void
            unsafeBitCast(implementation, to: SemanticContextSetter.self)(toolbarItemHost, selector, 4)
        }
        addSubview(toolbarItemHost)
        toolbarItemHost.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbarItemHost.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbarItemHost.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbarItemHost.topAnchor.constraint(equalTo: topAnchor),
            toolbarItemHost.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame:).")
    }
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        defer { super.viewWillMove(toWindow: newWindow) }
        
        observations.removeAll()
        guard let newWindow else { return }
        
        [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton]
            .compactMap(newWindow.standardWindowButton)
            .forEach { button in
                addSubview(button)
                // sub_32380 / sub_32684: restore the native button if AppKit reparents it.
                observations.append(button.observe(\.superview, options: [.new]) {
                    [weak self] button, _ in
                    MainActor.assumeIsolated {
                        guard let self, button.superview !== self else { return }
                        self.addSubview(button)
                    }
                })
            }
    }
}
