import CoreGraphics

struct WindowChromeGeometry: Sendable {
    let contentSize: CGSize
    let contentCornerRadius: CGFloat
    let titlebarHeight: CGFloat

    // sub_44b3c / sub_44b44: margins 6, total width padding 12.
    static let margin: CGFloat = 6

    var windowSize: CGSize {
        CGSize(
            width: contentSize.width + 2 * Self.margin,
            height: contentSize.height + titlebarHeight + Self.margin
        )
    }

    // Coordinates use a top-left origin, matching SwiftUI hover locations.
    var contentRect: CGRect {
        CGRect(
            x: Self.margin, y: titlebarHeight,
            width: contentSize.width, height: contentSize.height
        )
    }

    // Portrait branch of sub_3f230 / sub_3e9d8.
    func chromeRect(isPresented: Bool) -> CGRect {
        isPresented ? CGRect(origin: .zero, size: windowSize) : contentRect
    }

    func topCornerRadius(isPresented: Bool) -> CGFloat {
        isPresented ? 10 : contentCornerRadius
    }

    func bottomCornerRadius(isPresented: Bool) -> CGFloat {
        contentCornerRadius + (isPresented ? 3 : 0)
    }
}
