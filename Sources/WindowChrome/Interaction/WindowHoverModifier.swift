import SwiftUI

struct WindowHoverModifier: ViewModifier {
    let contentRect: CGRect
    @Binding var region: WindowHoverRegion

    func body(content: Content) -> some View {
        content.onContinuousHover(coordinateSpace: .global) { phase in
            switch phase {
            case .active(let location):
                region = .classify(location: location, contentRect: contentRect)
            case .ended:
                region = .none
            }
        }
    }
}
