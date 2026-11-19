import Foundation

/// Totals, averages, breakdowns and records across a set of catches, for the stats screen.
/// Shinies that got away count as found: they're in the totals, averages, years and records, since the encounters
/// were spent all the same. The ball, game and method breakdowns only count caught shinies, matching the collection.
/// Catches logged before catch history (no date, 0 encounters) count towards totals and breakdowns,
/// but averages and records only use catches with encounters logged, so they aren't dragged towards zero.
struct CatchStats {
	struct YearStat: Equatable {
		let year: Int
		/// Shinies found that year, caught or not.
		let shinies: Int
		/// Average over that year's catches with encounters logged; nil if none had any.
		let averageEncounters: Int?
	}

	struct Usage<Key: Hashable>: Equatable {
		let key: Key
		let count: Int
	}

	/// Every shiny found, caught or not.
	let totalShinies: Int
	let caughtCount: Int
	let failedCount: Int
	/// Share of found shinies that were caught, as a whole percentage; nil with none found.
	let catchRate: Int?
	/// Species caught at least once.
	let speciesCount: Int
	let totalEncounters: Int
	/// How many catches have encounters logged, which is what averages and records are based on.
	let catchesWithEncounters: Int
	let averageEncounters: Int?
	/// Oldest year first. Undated catches aren't in any year; see `undatedCount`.
	let years: [YearStat]
	let undatedCount: Int
	/// Most used first; ties are broken alphabetically so the order is stable.
	let ballUsage: [Usage<String>]
	let gameUsage: [Usage<Games>]
	let methodUsage: [Usage<HuntMethod>]
	/// The catch with the fewest encounters (above zero) and the one with the most.
	let fastestCatch: Catch?
	let longestCatch: Catch?

	init(catches: [Catch], calendar: Calendar = .current) {
		let caught = catches.filter { !$0.isFailed }
		totalShinies = catches.count
		caughtCount = caught.count
		failedCount = catches.count - caught.count
		catchRate = catches.isEmpty ? nil : Int((Double(caught.count) / Double(catches.count) * 100).rounded())
		speciesCount = Set(caught.map { $0.number }).count
		totalEncounters = catches.reduce(0) { $0 + $1.encounters }

		let withEncounters = catches.filter { $0.encounters > 0 }
		catchesWithEncounters = withEncounters.count
		averageEncounters = CatchStats.average(of: withEncounters)

		let dated = catches.filter { $0.caughtDate != nil }
		undatedCount = catches.count - dated.count
		let byYear = Dictionary(grouping: dated) { calendar.component(.year, from: $0.caughtDate!) }
		years = byYear.keys.sorted().map { year in
			let yearCatches = byYear[year]!
			return YearStat(year: year,
							shinies: yearCatches.count,
							averageEncounters: CatchStats.average(of: yearCatches.filter { $0.encounters > 0 }))
		}

		ballUsage = CatchStats.usage(of: caught.map { $0.caughtBall }.filter { $0 != CatchRules.noBall }, name: { $0 })
		gameUsage = CatchStats.usage(of: caught.map { $0.game }, name: { $0.displayName })
		methodUsage = CatchStats.usage(of: caught.map { $0.huntMethod }, name: { $0.rawValue })

		fastestCatch = withEncounters.min { $0.encounters < $1.encounters }
		longestCatch = withEncounters.max { $0.encounters < $1.encounters }
	}

	fileprivate static func average(of catches: [Catch]) -> Int? {
		guard !catches.isEmpty else { return nil }
		let total = catches.reduce(0) { $0 + $1.encounters }
		return Int((Double(total) / Double(catches.count)).rounded())
	}

	fileprivate static func usage<Key: Hashable>(of keys: [Key], name: (Key) -> String) -> [Usage<Key>] {
		let counts = Dictionary(keys.map { ($0, 1) }, uniquingKeysWith: +)
		return counts.map { Usage(key: $0.key, count: $0.value) }.sorted {
			$0.count != $1.count ? $0.count > $1.count : name($0.key) < name($1.key)
		}
	}
}
