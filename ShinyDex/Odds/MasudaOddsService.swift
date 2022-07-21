import Foundation

class MasudaOddsService {
	func getOdds(generation: Int, isCharmActive: Bool) -> Int {
		if (generation == 4) {
			return 1638
		}
		else if (generation == 5) {
            return isCharmActive ? 1024 : 1365
		}
        return isCharmActive ? 512 : 683
	}
}
