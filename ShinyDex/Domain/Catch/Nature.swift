import Foundation

enum Nature: String, CaseIterable {
	case hardy, lonely, brave, adamant, naughty
	case bold, docile, relaxed, impish, lax
	case timid, hasty, serious, jolly, naive
	case modest, mild, quiet, bashful, rash
	case calm, gentle, sassy, careful, quirky

	var name: String {
		return rawValue.capitalized
	}

	var raisedStat: Stat? {
		return effect?.raised
	}

	var loweredStat: Stat? {
		return effect?.lowered
	}

	var isNeutral: Bool {
		return effect == nil
	}

	var effectSummary: String {
		guard let effect = effect else { return "Neutral" }
		return "+\(effect.raised.shortName) −\(effect.lowered.shortName)"
	}

	static let gridStats: [Stat] = [.attack, .defense, .speed, .specialAttack, .specialDefense]

	static var grid: [[Nature]] {
		return stride(from: 0, to: allCases.count, by: gridStats.count).map { Array(allCases[$0..<$0 + gridStats.count]) }
	}

	fileprivate var effect: (raised: Stat, lowered: Stat)? {
		let gridIndex = Nature.allCases.firstIndex(of: self)!
		let raisedStatForRow = Nature.gridStats[gridIndex / Nature.gridStats.count]
		let loweredStatForColumn = Nature.gridStats[gridIndex % Nature.gridStats.count]
		let effectCancelsOut = raisedStatForRow == loweredStatForColumn
		return effectCancelsOut ? nil : (raisedStatForRow, loweredStatForColumn)
	}
}
