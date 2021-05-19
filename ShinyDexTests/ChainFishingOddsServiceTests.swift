//
//  FriendSafariOddsServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 19/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class ChainFishingOddsServiceTests: XCTestCase {
	var chainFishinOddsService: ChainFishingOddsService!

	override func setUpWithError() throws {
		try super.setUpWithError()
		chainFishinOddsService = ChainFishingOddsService()
	}

	override func tearDownWithError() throws {
		chainFishinOddsService = nil
		try super.tearDownWithError()
	}

	func test_maxChainReachedCharmActive_returns96() throws {
		// Arrange
		let expectedOdds = 96

		// Act
		let actualOdds = chainFishinOddsService.getOdds(isShinyCharmActive: true, chain: 21)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}

	func test_maxChainReachedCharmInactive_returns100() throws {
		// Arrange
		let expectedOdds = 100

		// Act
		let actualOdds = chainFishinOddsService.getOdds(isShinyCharmActive: false, chain: 21)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}

	func test_maxChainNotReachedCharmInactive_returnsCorrectOdds() throws {
		// Arrange
		let entries = [0: 4096, 1: 1365, 2: 819, 3: 585, 4: 455, 5: 372, 6: 315, 7: 273, 8: 240, 9: 215, 10: 195,
					   11: 178, 12: 163, 13: 151, 14: 141, 15: 132, 16: 124, 17: 117, 18: 110, 19: 105]

		// Act + Assert
		for entry in entries {
			let actualOdds = chainFishinOddsService.getOdds(isShinyCharmActive: false, chain: entry.key)
			XCTAssert(actualOdds == entry.value)
		}
	}

	func test_maxChainNotReachedCharmActive_returnsCorrectOdds() throws {
		// Arrange
		let entries = [0: 1365, 1: 819, 2: 585, 3: 455, 4: 372, 5: 315, 6: 273, 7: 240, 8: 215, 9: 195, 10: 178,
					   11: 163, 12: 151, 13: 141, 14: 132, 15: 124, 16: 117, 17: 110, 18: 105, 19: 99]

		// Act + Assert
		for entry in entries {
			let actualOdds = chainFishinOddsService.getOdds(isShinyCharmActive: true, chain: entry.key)
			XCTAssert(actualOdds == entry.value)
		}
	}
}
