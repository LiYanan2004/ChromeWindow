import SwiftUI

extension View {
    /// Places controls at the trailing edge of the enclosing ChromeWindow's titlebar.
    public func chromeWindowToolbar<ToolbarContent: View>(
        @ViewBuilder content: () -> ToolbarContent
    ) -> some View {
        preference(key: WindowTitlebarPreferenceKey.self, value: AnyView(content()))
    }
}
