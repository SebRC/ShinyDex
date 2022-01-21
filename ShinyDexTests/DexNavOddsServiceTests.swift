import XCTest
@testable import ShinyDex

class DexNavOddsServiceTests: XCTestCase {
	var dexNavOddsService: DexNavOddsService!

    override func setUpWithError() throws {
		try super.setUpWithError()
		dexNavOddsService = DexNavOddsService()
    }

    override func tearDownWithError() throws {
        dexNavOddsService = nil
		try super.tearDownWithError()
    }

    func test_differentSearchLevelsCharmInactive_returnsCorrectOdds() throws {
		// Arrange
		let entries = [50: 1689, 100: 1064, 200: 853, 800: 536, 999: 476, 1500: 373, 5000: 149]

		// Act + Assert
		for entry in entries {
			let actualOdds = dexNavOddsService.getOdds(searchLevel: entry.key, isShinyCharmActive: false)
			XCTAssertEqual(actualOdds, entry.value)
		}
    }

	func test_differentSearchLevelsCharmActive_returnsCorrectOdds() throws {
		// Arrange
		let entries = [50: 596, 100: 381, 200: 307, 800: 194, 999: 173, 1500: 136, 5000: 55]

		// Act + Assert
		for entry in entries {
			let actualOdds = dexNavOddsService.getOdds(searchLevel: entry.key, isShinyCharmActive: true)
			XCTAssertEqual(actualOdds, entry.value)
		}
	}

}
