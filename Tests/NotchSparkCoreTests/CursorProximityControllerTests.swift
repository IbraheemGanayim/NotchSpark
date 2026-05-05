import CoreGraphics
@testable import NotchSparkCore
import XCTest

final class CursorProximityControllerTests: XCTestCase {
    private let screen = ScreenSnapshot(
        frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
        visibleFrame: CGRect(x: 0, y: 25, width: 1440, height: 850)
    )

    func testTriggersOnceWhenEnteringZone() {
        var triggerCount = 0
        let controller = makeController {
            triggerCount += 1
        }

        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 80, y: 500), now: 0))
        XCTAssertTrue(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 1))
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 721, y: 869), now: 2))
        XCTAssertEqual(triggerCount, 1)
    }

    func testCooldownBlocksFastReentry() {
        var triggerCount = 0
        let controller = makeController(cooldown: 8) {
            triggerCount += 1
        }

        XCTAssertTrue(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 10))
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 80, y: 500), now: 11))
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 12))
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 80, y: 500), now: 17))
        XCTAssertTrue(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 18.1))
        XCTAssertEqual(triggerCount, 2)
    }

    func testDisabledStateDoesNotTrigger() {
        var triggerCount = 0
        let controller = makeController {
            triggerCount += 1
        }
        controller.isEnabled = false

        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 1))
        XCTAssertEqual(triggerCount, 0)

        controller.isEnabled = true
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 721, y: 869), now: 2))
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 80, y: 500), now: 3))
        XCTAssertTrue(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 4))
        XCTAssertEqual(triggerCount, 1)
    }

    func testManualShowStartsCooldown() {
        var triggerCount = 0
        let controller = makeController(cooldown: 8) {
            triggerCount += 1
        }

        controller.noteManualShow(now: 10)
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 11))
        XCTAssertFalse(controller.tick(mouseLocation: CGPoint(x: 80, y: 500), now: 12))
        XCTAssertTrue(controller.tick(mouseLocation: CGPoint(x: 720, y: 870), now: 18.1))
        XCTAssertEqual(triggerCount, 1)
    }

    private func makeController(
        cooldown: TimeInterval = 8,
        onTrigger: @escaping () -> Void
    ) -> CursorProximityController {
        CursorProximityController(
            cooldown: cooldown,
            cursorProvider: { CGPoint(x: 0, y: 0) },
            screenProvider: { [self.screen] },
            onTrigger: { _ in onTrigger() }
        )
    }
}
