import CoreGraphics
import Foundation

public struct EdgeInsetsSnapshot: Equatable, Sendable {
    public let top: CGFloat
    public let left: CGFloat
    public let bottom: CGFloat
    public let right: CGFloat

    public init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

public struct ScreenSnapshot: Equatable, Sendable {
    public let frame: CGRect
    public let visibleFrame: CGRect
    public let safeAreaInsets: EdgeInsetsSnapshot
    public let auxiliaryTopLeftArea: CGRect
    public let auxiliaryTopRightArea: CGRect

    public init(
        frame: CGRect,
        visibleFrame: CGRect,
        safeAreaInsets: EdgeInsetsSnapshot = EdgeInsetsSnapshot(),
        auxiliaryTopLeftArea: CGRect = .zero,
        auxiliaryTopRightArea: CGRect = .zero
    ) {
        self.frame = frame
        self.visibleFrame = visibleFrame
        self.safeAreaInsets = safeAreaInsets
        self.auxiliaryTopLeftArea = auxiliaryTopLeftArea
        self.auxiliaryTopRightArea = auxiliaryTopRightArea
    }
}

public struct NotchMetrics: Equatable, Sendable {
    public let screenFrame: CGRect
    public let center: CGPoint
    public let triggerZone: CGRect
    public let bubbleAnchor: CGPoint
    public let notchWidth: CGFloat
    public let notchHeight: CGFloat
    public let hasDetectedNotch: Bool
}

public enum NotchGeometry {
    public static func metrics(for screen: ScreenSnapshot) -> NotchMetrics {
        let frame = screen.frame.standardized
        let topY = frame.maxY
        let leftArea = screen.auxiliaryTopLeftArea.standardized
        let rightArea = screen.auxiliaryTopRightArea.standardized

        let hasAuxiliaryGap = !leftArea.isEmpty
            && !rightArea.isEmpty
            && rightArea.minX > leftArea.maxX
            && leftArea.maxY <= topY + 1
            && rightArea.maxY <= topY + 1

        let detectedGapWidth = hasAuxiliaryGap ? rightArea.minX - leftArea.maxX : 0
        let hasDetectedNotch = detectedGapWidth >= 80

        let centerX = hasDetectedNotch
            ? leftArea.maxX + (detectedGapWidth / 2)
            : frame.midX

        let detectedShelfHeight = hasDetectedNotch
            ? max(topY - min(leftArea.minY, rightArea.minY), 0)
            : 0

        let notchWidth = hasDetectedNotch
            ? detectedGapWidth
            : min(max(frame.width * 0.17, 154), 216)

        let notchHeight = max(34, detectedShelfHeight, min(screen.safeAreaInsets.top, 82))
        let triggerWidth = hasDetectedNotch
            ? min(frame.width, notchWidth)
            : min(frame.width, max(142, min(notchWidth, 176)))
        let triggerHeight = hasDetectedNotch
            ? notchHeight
            : 44
        let triggerX = clamp(centerX - (triggerWidth / 2), min: frame.minX, max: frame.maxX - triggerWidth)
        let triggerZone = CGRect(
            x: triggerX,
            y: topY - triggerHeight,
            width: triggerWidth,
            height: triggerHeight
        )

        let bubbleAnchor = CGPoint(
            x: centerX,
            y: topY - notchHeight - 10
        )

        return NotchMetrics(
            screenFrame: frame,
            center: CGPoint(x: centerX, y: topY - (notchHeight / 2)),
            triggerZone: triggerZone,
            bubbleAnchor: bubbleAnchor,
            notchWidth: notchWidth,
            notchHeight: notchHeight,
            hasDetectedNotch: hasDetectedNotch
        )
    }

    private static func clamp(_ value: CGFloat, min minimum: CGFloat, max maximum: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}
