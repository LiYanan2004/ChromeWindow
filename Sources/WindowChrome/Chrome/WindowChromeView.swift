import SwiftUI
import SwiftUI_WindowPrivate

struct WindowChromeView<Content: View>: View {
    @Environment(\.isWindowSharingIndicatorVisible) private var isWindowSharingIndicatorVisible
    let model: WindowChromeModel
    let updateTitlebarHeight: (CGFloat) -> Void
    let content: Content

    var body: some View {
        let geometry = model.geometry
        let chromeShape = UnevenRoundedRectangle(
            topLeadingRadius: geometry.topCornerRadius(isPresented: model.isPresented),
            bottomLeadingRadius: geometry.bottomCornerRadius(isPresented: model.isPresented),
            bottomTrailingRadius: geometry.bottomCornerRadius(isPresented: model.isPresented),
            topTrailingRadius: geometry.topCornerRadius(isPresented: model.isPresented),
            style: .continuous
        )
        let windowShape = chromeShape
            .size(geometry.chromeRect(isPresented: model.isPresented).size, anchor: .center)
            .offset(y: model.isPresented ? 0 : (geometry.titlebarHeight - 6) / 2)

        return WindowTitlebarPreferenceKey._delay { titlebarPreference in
            content
                .onGeometryChange(for: CGSize.self) { geometryProxy in
                    geometryProxy.size
                } action: { contentSize in
                    let geometry = model.geometry
                    guard contentSize != geometry.contentSize else { return }
                    model.geometry = WindowChromeGeometry(
                        contentSize: contentSize,
                        contentCornerRadius: geometry.contentCornerRadius,
                        titlebarHeight: geometry.titlebarHeight
                    )
                }
                .clipShape(.rect(cornerRadius: geometry.contentCornerRadius, style: .continuous))
                .padding([.horizontal, .bottom], WindowChromeGeometry.margin)
                .onGeometryChange(for: CGFloat.self) { geometryProxy in
                    geometryProxy.safeAreaInsets.top
                } action: { titlebarHeight in
                    // sub_52138 / sub_52164: accept nonzero system top insets.
                    if titlebarHeight > 0 {
                        updateTitlebarHeight(titlebarHeight)
                    }
                }
                .windowContentShape(windowShape, sizingBehavior: .none)
                .modifier(WindowContentInteractionModifier(geometry: geometry, model: model))
                .containerBackground(for: .window) {
                    WindowChromeBackground(
                        geometry: geometry, model: model, titlebarPreference: titlebarPreference
                    )
                }
                .onChange(of: isWindowSharingIndicatorVisible, initial: true) { _, isVisible in
                    model.setWindowSharingIndicatorVisible(isVisible)
                }
        }
    }
}
