import Foundation

// Pure rules for catches, kept free of Core Data so they can be unit tested.
enum CatchRules {
	static let noBall = "none"

	// Oldest first. Catches without a date were logged before catch history existed, so they come first.
	static func sorted(_ catches: [Catch]) -> [Catch] {
		return catches.enumerated().sorted { lhs, rhs in
			switch (lhs.element.caughtDate, rhs.element.caughtDate) {
			case let (left?, right?):
				return left == right ? lhs.offset < rhs.offset : left < right
			case (nil, .some):
				return true
			case (.some, nil):
				return false
			case (nil, nil):
				return lhs.offset < rhs.offset
			}
		}.map { $0.element }
	}

	static func latestBall(of catches: [Catch]) -> String {
		return sorted(catches).last?.caughtBall ?? noBall
	}

	static func countsByNumber(_ catches: [Catch]) -> [Int: Int] {
		return catches.reduce(into: [Int: Int]()) { counts, caught in
			counts[caught.number, default: 0] += 1
		}
	}

	static func isCaught(caughtBall: String) -> Bool {
		return !caughtBall.isEmpty && caughtBall != noBall
	}

	// Species marked as caught in the old single-catch data that have no catch history yet.
	// Skipping species that already have catches makes the copy safe to run more than once.
	static func pokemonToBackfill(from allPokemon: [Pokemon], existingCounts: [Int: Int]) -> [Pokemon] {
		return allPokemon.filter { isCaught(caughtBall: $0.caughtBall) && existingCounts[$0.number] == nil }
	}
}
