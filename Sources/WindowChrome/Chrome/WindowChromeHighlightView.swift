import SwiftUI
import SwiftUI_WindowPrivate

struct WindowChromeHighlightView: View {
    let geometry: WindowChromeGeometry
    let isPresented: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        // sub_3d878 / sub_3dde0 / sub_3e224: two sharp inner highlights at the top edge.
        let firstOpacity = colorScheme == .light ? 0.125
            : (colorSchemeContrast == .increased ? 0.25 : 0.1)
        let secondOpacity = colorScheme == .light ? 0.2
            : (colorSchemeContrast == .increased ? 0.4 : 0.11)
        let topRadius = isPresented ? 10 : geometry.contentCornerRadius

        UnevenRoundedRectangle(
            topLeadingRadius: topRadius, bottomLeadingRadius: 0,
            bottomTrailingRadius: 0, topTrailingRadius: topRadius,
            style: .continuous
        )
        .fill(Color.clear
            .shadow(.inner(color: .white.opacity(firstOpacity), radius: 0, y: 1).ignoresFill(true))
            .shadow(.inner(color: .white.opacity(secondOpacity), radius: 0, y: 0.5).ignoresFill(true)))
        .opacity(isPresented ? 1 : 0)
        .padding(.horizontal, isPresented ? 0 : WindowChromeGeometry.margin)
        .padding(.top, isPresented ? 0 : geometry.titlebarHeight)
    }
}
