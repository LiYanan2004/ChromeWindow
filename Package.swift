// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChromeWindow",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "ChromeWindow",
            targets: ["ChromeWindow"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SwiftUI_WindowPrivate",
            path: "Sources/DarwinPrivateFrameworkOverlay/SwiftUI_WindowPrivate.xcframework"
        ),
        .target(
            name: "ChromeWindow",
            dependencies: [
                "SwiftUI_WindowPrivate",
            ],
            path: "Sources/WindowChrome",
            linkerSettings: [
//                .
            ]
        ),
    ]
)
