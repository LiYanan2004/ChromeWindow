import CoreGraphics

// Raw values recovered from HoverState and sub_316b4.
enum WindowHoverRegion: Int, CaseIterable, Sendable {
    case none
    case titlebar
    case contentTopEdge
    case content
    case chrome
    
    static func classify(location: CGPoint?, contentRect: CGRect) -> Self {
        guard let location else { return .none }
        if contentRect.contains(location) {
            return location.y - contentRect.minY < 10 ? .contentTopEdge : .content
        }
        return location.y < contentRect.minY ? .titlebar : .chrome
    }
    
    func presentsContentChrome(after previousRegion: Self) -> Bool {
        switch self {
            case .titlebar, .contentTopEdge: true
            case .none, .content: false
            case .chrome: previousRegion != .none && previousRegion != .content
        }
    }
    
    func presentsBackgroundChrome(after previousRegion: Self) -> Bool {
        switch self {
            case .none, .contentTopEdge, .content: false
            case .titlebar: true
            case .chrome: previousRegion != .none && previousRegion != .content
        }
    }
}
