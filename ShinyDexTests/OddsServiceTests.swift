import XCTest
@testable import ShinyDex

class OddsServiceTests: XCTestCase {
	var oddsService: OddsService!

    override func setUpWithError() throws {
		try super.setUpWithError()
		oddsService = OddsService()
    }

    override func tearDownWithError() throws {
        oddsService = nil
		try super.tearDownWithError()
    }

    func test_differentMethods_defaultOddsForChosenService() throws {
        // Arrange
		let pokemon = Pokemon()
		pokemon.generation = 4
		pokemon.encounters = 0
		let entries = [HuntMethod.Gen2Breeding: 64, HuntMethod.Masuda: 1638, HuntMethod.Pokeradar: 8192,
					   HuntMethod.FriendSafari: 819, HuntMethod.ChainFishing: 4096, HuntMethod.DexNav: 4096, HuntMethod.SosChaining: 4096]

		// Act + Assert
		for entry in entries {
			pokemon.huntMethod = entry.key
			let actualOdds = oddsService.getShinyOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, entry.value)
		}
    }

	func test_preGen6CharmInactive_returnsBaseOdds() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.isShinyCharmActive = false
		let generations = [2, 4, 5]

		// Act + Assert
		for generation in generations {
			pokemon.generation = generation
			let actualOdds = oddsService.getShinyOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, 8192)
		}
	}

	func test_generation5CharmActive_returnsIncreasedOdds() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.isShinyCharmActive = true
		pokemon.generation = 5

		// Act
		let actualOdds = oddsService.getShinyOdds(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actualOdds, 2731)
	}

	func test_postGen5CharmInactive_returnsHalvedOdds() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.isShinyCharmActive = false
		let generations = [6, 7, 8]

		// Act + Assert
		for generation in generations {
			pokemon.generation = generation
			let actualOdds = oddsService.getShinyOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, 4096)
		}
	}

	func test_postGen5CharmActive_returnsHalvedOdds() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.isShinyCharmActive = true
		let generations = [6, 7, 8]

		// Act + Assert
		for generation in generations {
			pokemon.generation = generation
			let actualOdds = oddsService.getShinyOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, 1365)
		}
	}

	func test_lgpe_returnsHalvedOdds() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.isShinyCharmActive = false
		pokemon.generation = 0

		// Act
		let actualOdds = oddsService.getShinyOdds(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actualOdds, 4096)
	}
}
