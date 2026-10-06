import SwiftUI

struct WindowToolbarItems: View {
    var content: AnyView?

    var body: some View {
        HStack { content }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .padding(.trailing, 8)
    }

    // The hosting view supplies the original toolbar semantic context.
}
