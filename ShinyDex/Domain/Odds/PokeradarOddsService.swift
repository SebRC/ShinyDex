import Foundation

class PokeradarOddsService {
	static let firstGenerationWithDoubledOdds = 6

	func getOdds(chain: Int, generation: Int) -> Int {
		let odds = getSinnohOdds(chain: chain)
		return generation >= PokeradarOddsService.firstGenerationWithDoubledOdds ? odds / 2 : odds
	}

	fileprivate func getSinnohOdds(chain: Int) -> Int {
		if (chain <= 0) {
			return 8192
		}
		else if (chain >= 40) {
			return 200
		}
		return calculateOdds(chain: chain)
	}

	fileprivate func calculateOdds(chain: Int) -> Int {
		let baseNumber = 65536
		let divider = 8200 - chain * 200
		let oddsOfBaseNumber = baseNumber / divider
		let odds = baseNumber / oddsOfBaseNumber
		return odds
	}
}
