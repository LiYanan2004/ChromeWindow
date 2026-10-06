//
//  ChromeWindowApp.swift
//  ChromeWindowApp
//
//  Created by Yanan Li on 2026/10/6.
//

import SwiftUI
import ChromeWindow

@main
struct WindowChromeDemoApp: App {
    var body: some Scene {
        Window("ChromeWindow Demo", id: "demo") {
            ChromeWindowLauncherView()
        }
        .windowResizability(.contentSize)

        ChromeWindow(id: "chrome-window") {
            ContentView()
                .frame(width: 338, height: 734)
                .chromeWindowToolbar {
                    ForEach(1..<3) { i in
                        Button("\(i)", systemImage: "\(i).circle") {
                            print("\(i) clicked.")
                        }
                    }
                }
        }
        .defaultLaunchBehavior(.suppressed)
    }
}
