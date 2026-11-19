import Foundation

/// Limits as in the games since generation 6.
struct EffortValues: Equatable {
	enum Stat: Int, CaseIterable {
		case hp, attack, defense, specialAttack, specialDefense, speed

		var name: String {
			switch self {
			case .hp: return "HP"
			case .attack: return "Attack"
			case .defense: return "Defense"
			case .specialAttack: return "Sp. Atk"
			case .specialDefense: return "Sp. Def"
			case .speed: return "Speed"
			}
		}

		var shortName: String {
			switch self {
			case .hp: return "HP"
			case .attack: return "Atk"
			case .defense: return "Def"
			case .specialAttack: return "SpA"
			case .specialDefense: return "SpD"
			case .speed: return "Spe"
			}
		}
	}

	static let maximumPerStat = 252
	static let maximumTotal = 510

	fileprivate(set) var values: [Int]

	init() {
		values = Array(repeating: 0, count: Stat.allCases.count)
	}

	init(encoded: String?) {
		self.init()
		guard let parts = encoded?.split(separator: ",").map({ Int($0) }), parts.count == values.count, !parts.contains(nil) else { return }
		for (index, value) in parts.enumerated() {
			values[index] = value!
		}
		values = EffortValues.clamped(values)
	}

	var encoded: String {
		return values.map(String.init).joined(separator: ",")
	}

	var total: Int {
		return values.reduce(0, +)
	}

	var remaining: Int {
		return EffortValues.maximumTotal - total
	}

	var isEmpty: Bool {
		return total == 0
	}

	subscript(stat: Stat) -> Int {
		return values[stat.rawValue]
	}

	func adding(_ amount: Int, to stat: Stat) -> EffortValues {
		var copy = self
		let current = values[stat.rawValue]
		let ceiling = min(EffortValues.maximumPerStat, current + remaining)
		copy.values[stat.rawValue] = min(max(current + amount, 0), ceiling)
		return copy
	}

	func setting(_ value: Int, for stat: Stat) -> EffortValues {
		return adding(value - values[stat.rawValue], to: stat)
	}

	var summary: String {
		let trained = Stat.allCases.filter { values[$0.rawValue] > 0 }.sorted { values[$0.rawValue] > values[$1.rawValue] }
		return trained.isEmpty ? "Not trained" : trained.map { "\(values[$0.rawValue]) \($0.shortName)" }.joined(separator: " / ")
	}

	fileprivate static func clamped(_ values: [Int]) -> [Int] {
		var result = values.map { min(max($0, 0), maximumPerStat) }
		var excess = result.reduce(0, +) - maximumTotal
		for index in result.indices.reversed() where excess > 0 {
			let cut = min(result[index], excess)
			result[index] -= cut
			excess -= cut
		}
		return result
	}
}
