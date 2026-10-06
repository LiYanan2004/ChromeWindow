//
//  ChromeWindowLauncherView.swift
//  ChromeWindowApp
//
//  Created by Yanan Li on 2026/10/6.
//

import SwiftUI

struct ChromeWindowLauncherView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 16) {
            Text("ChromeWindow Demo")
                .font(.title2)

            Button("Open Chrome Window", systemImage: "macwindow") {
                openWindow(id: "chrome-window")
            }
            .accessibilityIdentifier("open-chrome-window")

            Text("Open again to focus the window, or close it and reopen it.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .fixedSize()
    }
}

#Preview {
    ChromeWindowLauncherView()
}
