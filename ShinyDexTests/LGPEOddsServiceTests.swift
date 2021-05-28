//
//  LGPEOddsServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 20/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class LGPEOddsServiceTests: XCTestCase {

	var lgpeOddsService: LGPEOddsService!

	override func setUpWithError() throws {
		try super.setUpWithError()
		lgpeOddsService = LGPEOddsService()
	}

	override func tearDownWithError() throws {
		lgpeOddsService = nil
		try super.tearDownWithError()
	}

	func test_tier4ComboCharmAndLureActive_returnsHighOdds() throws {
		// Arrange
		let expectedOdds = 1024
		let combos = [-1, 5, 10]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = true

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier4ComboCharmActiveLureInactive_returnsMediumOdds() throws {
		// Arrange
		let expectedOdds = 1365
		let combos = [-1, 5, 10]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = true

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier4ComboCharmInactiveLureActive_returnsLowOdds() throws {
		// Arrange
		let expectedOdds = 2048
		let combos = [-1, 5, 10]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = false

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier4ComboCharmAndLureInactive_returnsBaseOdds() throws {
		// Arrange
		let expectedOdds = 4096
		let combos = [-1, 5, 10]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = false

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier3ComboCharmAndLureActive_returnsHighOdds() throws {
		// Arrange
		let expectedOdds = 585
		let combos = [11, 15, 20]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = true

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier3ComboCharmActiveLureInactive_returnsMediumOdds() throws {
		// Arrange
		let expectedOdds = 683
		let combos = [11, 15, 20]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = true

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier3ComboCharmInactiveLureActive_returnsLowOdds() throws {
		// Arrange
		let expectedOdds = 819
		let combos = [11, 15, 20]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = false

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier3ComboCharmAndLureInactive_returnsBase1024() throws {
		// Arrange
		let expectedOdds = 1024
		let combos = [11, 15, 20]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = false

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier2ComboCharmAndLureActive_returnsHighOdds() throws {
		// Arrange
		let expectedOdds = 372
		let combos = [21, 25, 30]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = true

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier2ComboCharmActiveLureInactive_returnsMediumOdds() throws {
		// Arrange
		let expectedOdds = 410
		let combos = [21, 25, 30]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = true

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier2ComboCharmInactiveLureActive_returnsLowOdds() throws {
		// Arrange
		let expectedOdds = 455
		let combos = [21, 25, 30]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = false

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier2ComboCharmAndLureInactive_returnsBase512() throws {
		// Arrange
		let expectedOdds = 512
		let combos = [21, 25, 30]
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = false

		// Act + Assert
		for combo in combos {
			pokemon.encounters = combo
			let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)
			XCTAssertEqual(actualOdds, expectedOdds)
		}
	}

	func test_tier1ComboCharmAndLureActive_returnsHighOdds() throws {
		// Arrange
		let expectedOdds = 273
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = true
		pokemon.encounters = 35

		// Act
		let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actualOdds, expectedOdds)
	}

	func test_tier1ComboCharmActiveLureInactive_returnsMediumOdds() throws {
		// Arrange
		let expectedOdds = 293
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = true
		pokemon.encounters = 35

		// Act
		let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actualOdds, expectedOdds)
	}

	func test_tier1ComboCharmInactiveLureActive_returnsLowOdds() throws {
		// Arrange
		let expectedOdds = 315
		let pokemon = Pokemon()
		pokemon.huntMethod = .Lure
		pokemon.isShinyCharmActive = false
		pokemon.encounters = 35

		// Act
		let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actualOdds, expectedOdds)
	}

	func test_tier2ComboCharmAndLureInactive_returnsBase341() throws {
		// Arrange
		let expectedOdds = 341
		let pokemon = Pokemon()
		pokemon.huntMethod = .Encounters
		pokemon.isShinyCharmActive = false
		pokemon.encounters = 35

		// Act
		let actualOdds = lgpeOddsService.getOdds(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actualOdds, expectedOdds)
	}
}
