import CoreGraphics
@testable import NotchSparkCore
import XCTest

final class NotchGeometryTests: XCTestCase {
    func testDetectsNotchFromAuxiliaryTopAreas() {
        let screen = ScreenSnapshot(
            frame: CGRect(x: 0, y: 0, width: 3024, height: 1964),
            visibleFrame: CGRect(x: 0, y: 0, width: 3024, height: 1889),
            safeAreaInsets: EdgeInsetsSnapshot(top: 74),
            auxiliaryTopLeftArea: CGRect(x: 0, y: 1890, width: 1410, height: 74),
            auxiliaryTopRightArea: CGRect(x: 1614, y: 1890, width: 1410, height: 74)
        )

        let metrics = NotchGeometry.metrics(for: screen)

        XCTAssertTrue(metrics.hasDetectedNotch)
        XCTAssertEqual(metrics.notchWidth, 204, accuracy: 0.1)
        XCTAssertEqual(metrics.center.x, 1512, accuracy: 0.1)
        XCTAssertTrue(metrics.triggerZone.contains(CGPoint(x: 1512, y: 1928)))
        XCTAssertLessThan(metrics.bubbleAnchor.y, screen.frame.maxY)
    }

    func testFallsBackToTopCenterWithoutNotchAreas() {
        let screen = ScreenSnapshot(
            frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
            visibleFrame: CGRect(x: 0, y: 25, width: 1440, height: 850)
        )

        let metrics = NotchGeometry.metrics(for: screen)

        XCTAssertFalse(metrics.hasDetectedNotch)
        XCTAssertEqual(metrics.center.x, 720, accuracy: 0.1)
        XCTAssertTrue(metrics.triggerZone.contains(CGPoint(x: 720, y: 860)))
        XCTAssertFalse(metrics.triggerZone.contains(CGPoint(x: 100, y: 860)))
    }

    func testKeepsCoordinatesInTheirDisplayFrame() {
        let screen = ScreenSnapshot(
            frame: CGRect(x: 3024, y: 120, width: 1728, height: 1117),
            visibleFrame: CGRect(x: 3024, y: 120, width: 1728, height: 1060),
            safeAreaInsets: EdgeInsetsSnapshot(top: 48),
            auxiliaryTopLeftArea: CGRect(x: 3024, y: 1189, width: 760, height: 48),
            auxiliaryTopRightArea: CGRect(x: 3992, y: 1189, width: 760, height: 48)
        )

        let metrics = NotchGeometry.metrics(for: screen)

        XCTAssertTrue(metrics.hasDetectedNotch)
        XCTAssertEqual(metrics.center.x, 3888, accuracy: 0.1)
        XCTAssertGreaterThanOrEqual(metrics.triggerZone.minX, screen.frame.minX)
        XCTAssertLessThanOrEqual(metrics.triggerZone.maxX, screen.frame.maxX)
        XCTAssertGreaterThanOrEqual(metrics.bubbleAnchor.x, screen.frame.minX)
        XCTAssertLessThanOrEqual(metrics.bubbleAnchor.x, screen.frame.maxX)
    }
}
