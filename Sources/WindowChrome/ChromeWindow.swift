import SwiftUI
import SwiftUI_WindowPrivate

/// A window with chrome that expands when you hover near its top edge.
/// The window's size follows the layout constraints of its content and prevents manual resizing.
/// Provide a unique identifier to open the window with SwiftUI's `openWindow` action.
public struct ChromeWindow<Content: View>: Scene {
    private let title: String
    private let identifier: String
    private let contentCornerRadius: CGFloat
    private let content: Content

    public init(
        _ title: String = "Chrome Window",
        id: String,
        contentCornerRadius: CGFloat = 55,
        @ViewBuilder content: () -> Content
    ) {
        precondition(contentCornerRadius >= 0)
        self.title = title
        identifier = id
        self.contentCornerRadius = contentCornerRadius
        self.content = content()
    }

    public var body: some Scene {
        Window(title, id: identifier) {
            SceneContent(
                contentCornerRadius: contentCornerRadius, content: content
            )
        }
        .windowResizability(.contentSize)
        .windowInsets(EdgeInsets(top: 38, leading: 0, bottom: 0, trailing: 0))
        .windowToolbarStyle(.unifiedCompact)
    }

    private struct SceneContent: View {
        @State private var model: WindowChromeModel
        let content: Content

        init(contentCornerRadius: CGFloat, content: Content) {
            _model = State(initialValue: WindowChromeModel(geometry: WindowChromeGeometry(
                contentSize: .zero, contentCornerRadius: contentCornerRadius, titlebarHeight: 0
            )))
            self.content = content
        }

        var body: some View {
            WindowChromeView(
                model: model,
                updateTitlebarHeight: { titlebarHeight in
                    let geometry = model.geometry
                    guard titlebarHeight != geometry.titlebarHeight else { return }
                    model.geometry = WindowChromeGeometry(
                        contentSize: geometry.contentSize,
                        contentCornerRadius: geometry.contentCornerRadius,
                        titlebarHeight: titlebarHeight
                    )
                },
                content: content
            )
            .background(WindowConfigurationView().frame(width: 0, height: 0))
            .toolbarBackground(.hidden, for: .windowToolbar)
            .toolbar(removing: .title)
        }

        // Preview omitted: requires the SwiftUI Window scene and native frame controls.
    }

    private struct WindowConfigurationView: NSViewRepresentable {
        func makeNSView(context: Context) -> ConfigurationView { ConfigurationView() }
        func updateNSView(_ view: ConfigurationView, context: Context) {}

        final class ConfigurationView: NSView {
            private var windowStyleObservation: NSKeyValueObservation?

            override func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()
                windowStyleObservation = nil
                guard let window else { return }
                window.configureTitlebar()
                windowStyleObservation = window.observe(\.styleMask, options: [.initial]) { window, _ in
                    MainActor.assumeIsolated {
                        // SwiftUI updates resizability when the content's size constraints change.
                        guard window.styleMask.contains(.resizable) else { return }
                        window.styleMask.remove(.resizable)
                    }
                }
            }
        }
    }
}
