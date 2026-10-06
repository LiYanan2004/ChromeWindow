# ChromeWindow

A reproduction of the window effects of `iPhone Mirroring.app`.

It recreates the rounded window outline and shadow, the frame and titlebar that animate into view on hover, and the native window controls alongside custom toolbar items.

> [!WARNING]
> ChromeWindow uses private SwiftUI APIs. Use it at your own risks.

![](/Resources/ChromeWindow.gif)

## Requirements

- macOS 15+

## Getting Started

## Usage

### Create a Window

Declare a `ChromeWindow` scene in your app's `body`. Give it a unique identifier and provide your SwiftUI content:

```swift
ChromeWindow("Preview", id: "preview") {
    ContentView()
        .frame(width: 338, height: 734)
}
```

The window follows its content's layout size and updates when that size changes. Edge resizing is disabled, so set the desired size through your content's layout.

At rest, the content and window shadow remain visible. Hover near the top edge to reveal the frame and titlebar. The native window controls and any toolbar items appear together, and the expanded frame follows the content's rounded outline.

### Set the Corner Radius

Use `contentCornerRadius` to match your content's shape. The default is 55 points; values must be nonnegative.

```swift
ChromeWindow("Preview", id: "preview", contentCornerRadius: 24) {
    ContentView()
        .frame(width: 400, height: 600)
}
```

### Add Titlebar Controls

Apply `.chromeWindowToolbar` to the content inside a `ChromeWindow`. Its SwiftUI controls appear at the trailing edge of the titlebar and animate with the native window controls.

```swift
ContentView()
    .chromeWindowToolbar {
        Button("Refresh", systemImage: "arrow.clockwise") {
            print("Refresh clicked")
        }
        Button("Settings", systemImage: "gearshape") {
            print("Settings clicked")
        }
    }
```

## Sample App

Open [ChromeWindowApp.xcodeproj](ChromeWindowApp/ChromeWindowApp.xcodeproj) in Xcode, select the `ChromeWindowApp` scheme, and run it on macOS 15.7 or later.

Click **Open Chrome Window** to display the example. Hover near its top edge to reveal the titlebar and two sample toolbar buttons. Each button prints a message to the console.
