import AppKit
import NotchSparkCore

extension EdgeInsetsSnapshot {
    init(_ insets: NSEdgeInsets) {
        self.init(
            top: insets.top,
            left: insets.left,
            bottom: insets.bottom,
            right: insets.right
        )
    }
}

extension ScreenSnapshot {
    init(screen: NSScreen) {
        self.init(
            frame: screen.frame,
            visibleFrame: screen.visibleFrame,
            safeAreaInsets: EdgeInsetsSnapshot(screen.safeAreaInsets),
            auxiliaryTopLeftArea: screen.auxiliaryTopLeftArea ?? .zero,
            auxiliaryTopRightArea: screen.auxiliaryTopRightArea ?? .zero
        )
    }
}
