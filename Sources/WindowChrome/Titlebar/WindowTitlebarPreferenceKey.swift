import SwiftUI

struct WindowTitlebarPreferenceKey: PreferenceKey {
    static var defaultValue: AnyView? { nil }

    static func reduce(value: inout AnyView?, nextValue: () -> AnyView?) {
        value = nextValue() ?? value
    }
}
