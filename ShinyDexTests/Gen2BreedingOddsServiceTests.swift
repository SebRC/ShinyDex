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
