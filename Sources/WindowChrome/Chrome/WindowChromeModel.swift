import CoreGraphics
import Observation
import SwiftUI

@MainActor @Observable
final class WindowChromeModel {
    private var isPresentedForHover = false
    private var isWindowSharingIndicatorVisible = false
    var isPresented: Bool { isWindowSharingIndicatorVisible || isPresentedForHover }
    var geometry: WindowChromeGeometry

    init(geometry: WindowChromeGeometry) {
        self.geometry = geometry
    }
    func setPresented(_ shouldPresent: Bool) {
        guard shouldPresent != isPresentedForHover else { return }
        // sub_46cfc / sub_47384 write the same model from separate hover regions.
        withTransaction(WindowChromeAnimation.transaction) {
            isPresentedForHover = shouldPresent
        }
    }

    func setWindowSharingIndicatorVisible(_ isVisible: Bool) {
        guard isVisible != isWindowSharingIndicatorVisible else { return }
        // sub_524e8 / sub_6c22c: force chrome with the same spring transaction.
        withTransaction(WindowChromeAnimation.transaction) {
            isWindowSharingIndicatorVisible = isVisible
        }
    }
}
