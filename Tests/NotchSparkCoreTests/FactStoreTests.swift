@testable import NotchSparkCore
import XCTest

final class FactStoreTests: XCTestCase {
    func testFactsDoNotRepeatWithinOneBagCycle() {
        let facts = [
            FunFact(text: "Alpha", symbolName: "a.circle", paletteIndex: 0),
            FunFact(text: "Beta", symbolName: "b.circle", paletteIndex: 1),
            FunFact(text: "Gamma", symbolName: "g.circle", paletteIndex: 2)
        ]
        let store = FactStore(facts: facts)

        let pulledFacts = (0..<facts.count).map { _ in store.nextFact() }

        XCTAssertEqual(Set(pulledFacts), Set(facts))
    }

    func testFactStoreAvoidsImmediateCycleBoundaryRepeat() {
        let facts = [
            FunFact(text: "Alpha", symbolName: "a.circle", paletteIndex: 0),
            FunFact(text: "Beta", symbolName: "b.circle", paletteIndex: 1)
        ]
        let store = FactStore(facts: facts)

        let firstCycle = (0..<facts.count).map { _ in store.nextFact() }
        let firstOfNextCycle = store.nextFact()

        XCTAssertNotEqual(firstCycle.last, firstOfNextCycle)
    }

    func testDefaultFactsAreShortAndRenderable() {
        XCTAssertGreaterThan(FunFact.defaultFacts.count, 24)

        for fact in FunFact.defaultFacts {
            XCTAssertFalse(fact.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertLessThanOrEqual(fact.text.count, 82)
            XCTAssertFalse(fact.symbolName.isEmpty)
        }
    }
}
