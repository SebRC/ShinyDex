import Foundation

enum CatchRules {
	static let noBall = "none"

	static func sortedOldestFirst(_ catches: [Catch]) -> [Catch] {
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

	static func sortedForCollection(_ catches: [Catch]) -> [Catch] {
		return sortedOldestFirst(catches).enumerated().sorted { lhs, rhs in
			if (lhs.element.number == rhs.element.number) {
				return lhs.offset < rhs.offset
			}
			return lhs.element.number < rhs.element.number
		}.map { $0.element }
	}

	static func getLatestBall(of catches: [Catch]) -> String {
		return sortedOldestFirst(catches).last?.caughtBall ?? noBall
	}

	static func countByNumber(_ catches: [Catch]) -> [Int: Int] {
		return catches.reduce(into: [Int: Int]()) { counts, caught in
			counts[caught.number, default: 0] += 1
		}
	}

	static func parseEncounters(from text: String) -> Int? {
		guard let encounters = Int(text.trimmingCharacters(in: .whitespaces)), encounters >= 0 else {
			return nil
		}
		return encounters
	}

	static func isCaught(caughtBall: String) -> Bool {
		return !caughtBall.isEmpty && caughtBall != noBall
	}

	static func findPokemonToBackfill(from allPokemon: [Pokemon], existingCounts: [Int: Int]) -> [Pokemon] {
		return allPokemon.filter { isCaught(caughtBall: $0.caughtBall) && existingCounts[$0.number] == nil }
	}
}
