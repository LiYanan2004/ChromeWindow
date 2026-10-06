import SwiftUI

struct WindowContentInteractionModifier: ViewModifier {
    let geometry: WindowChromeGeometry
    let model: WindowChromeModel
    @State private var hoverRegion = WindowHoverRegion.none

    func body(content: Content) -> some View {
        content.overlay {
            // sub_46478: hover covers the padded content; only chrome intercepts clicks.
            Color.clear
                .contentShape(Rectangle())
                .allowsHitTesting(hoverRegion == .chrome)
                .modifier(WindowHoverModifier(
                    contentRect: geometry.contentRect, region: $hoverRegion
                ))
                .onChange(of: hoverRegion) { previousRegion, nextRegion in
                    model.setPresented(nextRegion.presentsContentChrome(after: previousRegion))
                }
                .gesture(WindowDragGesture(), including: hoverRegion == .chrome ? .all : .subviews)
                .allowsWindowActivationEvents(hoverRegion == .chrome)
                .ignoresSafeArea()
                // sub_46478 enables this gesture overlay only for a special
                // WindowState payload. The connected scene leaves it disabled.
                .environment(\.isEnabled, false)
        }
    }
}
