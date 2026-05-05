@testable import NotchSparkCore
import XCTest

final class BackdropContrastTests: XCTestCase {
    func testBrightBackdropUsesInkStyle() {
        XCTAssertEqual(BackdropContrast.style(forAverageLuminance: 0.9), .ink)
    }

    func testDarkBackdropUsesPaperStyle() {
        XCTAssertEqual(BackdropContrast.style(forAverageLuminance: 0.12), .paper)
    }

    func testMissingBackdropUsesSafeFallback() {
        XCTAssertEqual(BackdropContrast.style(forAverageLuminance: nil), .ink)
        XCTAssertEqual(BackdropContrast.style(forAverageLuminance: .nan), .ink)
    }
}
