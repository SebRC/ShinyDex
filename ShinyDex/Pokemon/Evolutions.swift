import Foundation

/// Evolution lines, from the bundled `evolutions.json` (PokeAPI's "evolves from" data, using the app's 0-based numbers).
/// A line is every species sharing a root, so branches like Eevee's are one line.
struct Evolutions {
	/// For each species number, the species it evolves from, or -1.
	let evolvesFrom: [Int]

	static let shared = Evolutions.loadBundled()

	init(evolvesFrom: [Int]) {
		self.evolvesFrom = evolvesFrom
	}

	fileprivate static func loadBundled() -> Evolutions {
		struct File: Decodable {
			let evolvesFrom: [Int]
		}
		guard let url = Bundle.main.url(forResource: "evolutions", withExtension: "json"),
			  let data = try? Data(contentsOf: url),
			  let file = try? JSONDecoder().decode(File.self, from: data) else {
			return Evolutions(evolvesFrom: [])
		}
		return Evolutions(evolvesFrom: file.evolvesFrom)
	}

	func parent(of number: Int) -> Int? {
		guard evolvesFrom.indices.contains(number), evolvesFrom[number] >= 0 else { return nil }
		return evolvesFrom[number]
	}

	/// The first species in the line.
	func root(of number: Int) -> Int {
		var current = number
		var seen = Set<Int>()
		while let parent = parent(of: current), !seen.contains(parent) {
			seen.insert(current)
			current = parent
		}
		return current
	}

	/// 0 for the first species in a line, 1 for its evolutions, and so on.
	func stage(of number: Int) -> Int {
		var stage = 0
		var current = number
		while let parent = parent(of: current), stage < 10 {
			stage += 1
			current = parent
		}
		return stage
	}

	/// Every species in the line, earliest stage first, then in dex order.
	func line(of number: Int) -> [Int] {
		let root = self.root(of: number)
		let members = evolvesFrom.indices.filter { $0 == root || self.root(of: $0) == root }
		return members.sorted { stage(of: $0) != stage(of: $1) ? stage(of: $0) < stage(of: $1) : $0 < $1 }
	}

	/// Species the given one can change into: the rest of its line. Empty for species that don't evolve.
	func evolutionTargets(of number: Int) -> [Int] {
		return line(of: number).filter { $0 != number }
	}
}
