import XCTest
@testable import ShinyDex

class GamesTests: XCTestCase {
	func test_displayName_capitalizesPearl_withoutChangingStoredValue() {
		XCTAssertEqual(Games.Pearl.displayName, "Pearl")
		XCTAssertEqual(Games.Pearl.rawValue, "pearl")
	}

	func test_displayName_keepsTheRestOfTheName() {
		XCTAssertEqual(Games.LetsGoPikachu.displayName, Games.LetsGoPikachu.rawValue)
	}

	func test_displayName_startsWithCapitalForEveryGame() {
		for game in Games.allCases {
			XCTAssertEqual(game.displayName.first.map { String($0) }, game.displayName.first.map { String($0).uppercased() }, game.rawValue)
		}
	}
}
