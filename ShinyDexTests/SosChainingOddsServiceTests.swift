//
//  SosChainingOddsServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 20/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class SosChainingOddsServiceTests: XCTestCase {

	var sosChainingOddsService: SosChainingOddsService!

	override func setUpWithError() throws {
		try super.setUpWithError()
		sosChainingOddsService = SosChainingOddsService()
	}

	override func tearDownWithError() throws {
		sosChainingOddsService = nil
		try super.tearDownWithError()
	}

	func test_differentChainsCharmInactive_returnsCorrectOdds() throws {
		// Arrange
		let entries = [-1: 4096, 5: 4096, 10: 4096, 11: 820, 15: 820, 20: 820, 21: 455, 25: 455, 30: 455, 50: 315]

		// Act + Assert
		for entry in entries {
			let actualOdds = sosChainingOddsService.getOdds(isShinyCharmActive: false, chain: entry.key)
			XCTAssertEqual(actualOdds, entry.value)
		}
	}

	func test_differentChainsCharmActive_returnsCorrectOdds() throws {
		// Arrange
		let entries = [-1: 1366, 5: 1366, 10: 1366, 11: 585, 15: 585, 20: 585, 21: 373, 25: 373, 30: 373, 50: 273]

		// Act + Assert
		for entry in entries {
			let actualOdds = sosChainingOddsService.getOdds(isShinyCharmActive: true, chain: entry.key)
			XCTAssertEqual(actualOdds, entry.value)
		}
	}
}
