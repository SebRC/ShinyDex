//
//  FriendSafariOddsServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 19/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class FriendSafariOddsServiceTests: XCTestCase {
	var friendSafariOddsService: FriendSafariOddsService!

    override func setUpWithError() throws {
		try super.setUpWithError()
		friendSafariOddsService = FriendSafariOddsService()
    }

    override func tearDownWithError() throws {
		friendSafariOddsService = nil
		try super.tearDownWithError()
    }

	func test_charmActive_returns585() throws {
		// Arrange
		let expectedOdds = 585

		// Act
		let actualOdds = friendSafariOddsService.getOdds(isShinyCharmActive: true)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}

	func test_charmInactive_returns819() throws {
		// Arrange
		let expectedOdds = 819

		// Act
		let actualOdds = friendSafariOddsService.getOdds(isShinyCharmActive: false)

		// Assert
		XCTAssert(actualOdds == expectedOdds)
	}
}
