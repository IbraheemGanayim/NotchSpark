import Foundation

public final class FactStore {
    private let facts: [FunFact]
    private var bag: [FunFact] = []
    private var lastFact: FunFact?

    public init(facts: [FunFact] = FunFact.defaultFacts) {
        let cleanedFacts = facts.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        self.facts = cleanedFacts.isEmpty
            ? [FunFact(text: "Curiosity is tiny, but it travels well.", symbolName: "sparkles", paletteIndex: 0)]
            : cleanedFacts
    }

    public var count: Int {
        facts.count
    }

    public func nextFact() -> FunFact {
        if bag.isEmpty {
            refillBag()
        }

        let fact = bag.removeLast()
        lastFact = fact
        return fact
    }

    private func refillBag() {
        bag = facts.shuffled()

        guard bag.count > 1, let lastFact, bag.last == lastFact else {
            return
        }

        bag.swapAt(bag.count - 1, 0)
    }
}
