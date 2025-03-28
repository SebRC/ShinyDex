import Foundation

class ChainFishingOddsService {
	func getOdds(isShinyCharmActive: Bool, chain: Int) -> Int {
		if (chain >= 20) {
			return isShinyCharmActive ? 96 : 100
		}
        return calculateOdds(isCharmActive: isShinyCharmActive, chain: chain)
	}

	fileprivate func calculateOdds(isCharmActive: Bool, chain: Int) -> Int {
		let baseNumber = isCharmActive ? 3 : 1
		return 4096 / (baseNumber + (chain * 2))
	}
}
