import Foundation

class LGPEOddsService {
	fileprivate var isShinyCharmActive = false
	fileprivate var isLureActive = false

	func getOdds(pokemon: Pokemon) -> Int {
		isShinyCharmActive = pokemon.isShinyCharmActive
		isLureActive = pokemon.huntMethod == HuntMethod.Lure
		let catchCombo = pokemon.encounters

		if (catchCombo >= 0 && catchCombo <= 10 || catchCombo < 0) {
			return getTier4Odds()
		}
		else if (catchCombo >= 11 && catchCombo <= 20) {
			return getTier3Odds()
		}
		else if (catchCombo >= 21 && catchCombo <= 30) {
			return getTier2Odds()
		}
		return getTier1Odds()
	}

	fileprivate func getTier4Odds() -> Int {
		if (isShinyCharmActive && isLureActive) {
			return 1024
		}
		else if (isShinyCharmActive) {
			return 1365
		}
		else if (isLureActive) {
			return 2048
		}
		return 4096
	}

	fileprivate func getTier3Odds() -> Int {
		if (isShinyCharmActive && isLureActive) {
			return 585
		}
		else if (isShinyCharmActive) {
			return 683
		}
		else if (isLureActive) {
			return 819
		}
		return 1024
	}

	fileprivate func getTier2Odds() -> Int {
		if (isShinyCharmActive && isLureActive) {
			return 372
		}
		else if (isShinyCharmActive) {
			return 410
		}
		else if (isLureActive) {
			return 455
		}
		return 512
	}

	fileprivate func getTier1Odds() -> Int {
		if (isShinyCharmActive && isLureActive) {
			return 273
		}
		else if (isShinyCharmActive) {
			return 293
		}
		else if (isLureActive) {
			return 315
		}
		return 341
	}
}
