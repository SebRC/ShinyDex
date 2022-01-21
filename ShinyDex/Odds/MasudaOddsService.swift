import Foundation

class MasudaOddsService {
	func getOdds(generation: Int, isCharmActive: Bool) -> Int {
		if (generation == 4) {
			return 1638
		}
		else if (generation == 5 && isCharmActive) {
			return 1024
		}
		else if (generation == 5) {
			return 1365
		}
		else if (generation > 5 && isCharmActive) {
			return 512
		}
		return 683
	}
}
