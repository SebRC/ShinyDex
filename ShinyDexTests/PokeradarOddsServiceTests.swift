//
//  PokeradarOddsServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 20/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class PokeradarOddsServiceTests: XCTestCase {

	var pokeradarOddsService: PokeradarOddsService!

	override func setUpWithError() throws {
		try super.setUpWithError()
		pokeradarOddsService = PokeradarOddsService()
	}

	override func tearDownWithError() throws {
		pokeradarOddsService = nil
		try super.tearDownWithError()
	}

	func test_differentChains_returnsCorrectOdds() throws {
		// Arrange
		let entries = [-1: 8192, 0: 8192, 1: 8192, 5: 7281, 9: 6553, 12: 5957, 21: 4096, 31: 2048, 39: 402, 40: 200, 45: 200]

		// Act + Assert
		for entry in entries {
			let actualOdds = pokeradarOddsService.getOdds(chain: entry.key)
			XCTAssertEqual(actualOdds, entry.value)
		}
	}

}
