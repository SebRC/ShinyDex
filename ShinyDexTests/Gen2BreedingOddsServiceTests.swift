//
//  Gen2BreedingOddsServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 19/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class Gen2BreedingOddsServiceTests: XCTestCase {
	var gen2BreedingOddsService: Gen2BreedingOddsService!

	override func setUpWithError() throws {
		try super.setUpWithError()
		gen2BreedingOddsService = Gen2BreedingOddsService()
	}

	override func tearDownWithError() throws {
		gen2BreedingOddsService = nil
		try super.tearDownWithError()
	}

	func test_getOdds_returns64() throws {
		// Arrange
		let expectedOdds = 64

		// Act
		let actualOdds = gen2BreedingOddsService.getOdds()

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}
}
