import SwiftUI

struct WindowChromeBackground: View {
    let geometry: WindowChromeGeometry
    let model: WindowChromeModel
    @State private var hoverRegion = WindowHoverRegion.none

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(.ultraThinMaterial)

            WindowChromeHighlightView(geometry: geometry, isPresented: model.isPresented)
                .transaction(value: model.isPresented) { transaction in
                    transaction.disablesAnimations = true
                }

            // sub_3d3f8 outlines the content, inset from the window's outer contour.
            RoundedRectangle(cornerRadius: geometry.contentCornerRadius, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
                .padding([.horizontal, .bottom], WindowChromeGeometry.margin)
                .padding(.top, geometry.titlebarHeight)
                .opacity(model.isPresented ? 1 : 0)

            WindowControlsView()
                .frame(height: geometry.titlebarHeight)
                .offset(y: model.isPresented ? 0 : geometry.titlebarHeight)
                .transaction(value: model.isPresented) { transaction in
                    WindowChromeAnimation.replaceAnimation(
                        in: &transaction, response: WindowChromeAnimation.geometryResponse
                    )
                }
                .opacity(model.isPresented ? 1 : 0)
                .transaction(value: model.isPresented) { transaction in
                    WindowChromeAnimation.replaceAnimation(
                        in: &transaction,
                        response: WindowChromeAnimation.titlebarOpacityResponse(
                            isPresented: model.isPresented
                        )
                    )
                }
        }
        .gesture(WindowDragGesture())
        .modifier(WindowHoverModifier(contentRect: geometry.contentRect, region: $hoverRegion))
        .onChange(of: hoverRegion) { previousRegion, nextRegion in
            model.setPresented(nextRegion.presentsBackgroundChrome(after: previousRegion))
        }
    }
}
