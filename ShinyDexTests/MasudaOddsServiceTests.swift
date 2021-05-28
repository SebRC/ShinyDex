//
//  MasudaOddsServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 19/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class MasudaOddsServiceTests: XCTestCase {
	var masudaOddsService: MasudaOddsService!

    override func setUpWithError() throws {
		try super.setUpWithError()
		masudaOddsService = MasudaOddsService()
    }

    override func tearDownWithError() throws {
        masudaOddsService = nil
		try super.tearDownWithError()
    }

    func test_generationIs4_returns1638() throws {
		// Arrange
		let expectedOdds = 1638

		// Act
		let actualOdds = masudaOddsService.getOdds(generation: 4, isCharmActive: false)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
    }

	func test_generationIs5CharmActive_returns1024() throws {
		// Arrange
		let expectedOdds = 1024

		// Act
		let actualOdds = masudaOddsService.getOdds(generation: 5, isCharmActive: true)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}

	func test_generationIs5CharmInactive_returns1365() throws {
		// Arrange
		let expectedOdds = 1365

		// Act
		let actualOdds = masudaOddsService.getOdds(generation: 5, isCharmActive: false)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}

	func test_postGeneration5CharmActive_returns512() throws {
		// Arrange
		let expectedOdds = 512

		// Act
		let actualOdds = masudaOddsService.getOdds(generation: 6, isCharmActive: true)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}

	func test_postGeneration5CharmActive_returns683() throws {
		// Arrange
		let expectedOdds = 683

		// Act
		let actualOdds = masudaOddsService.getOdds(generation: 6, isCharmActive: false)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}
}
