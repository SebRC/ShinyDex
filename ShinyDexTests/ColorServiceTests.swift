import XCTest
import UIKit
@testable import ShinyDex

class ColorServiceTests: XCTestCase {
	var colorService: ColorService!

    override func setUpWithError() throws {
		try super.setUpWithError()
		cleanColors()
		colorService = ColorService()
    }

    override func tearDownWithError() throws {
		cleanColors()
		colorService = nil
		try super.tearDownWithError()
    }

	fileprivate func cleanColors() {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: Theme.Primary.rawValue)
		defaults.removeObject(forKey: Theme.Secondary.rawValue)
		defaults.removeObject(forKey: Theme.Tertiary.rawValue)
	}

    func test_noPrimarySaved_returnsDefault() throws {
		// Arrange
		let expectedHex = 0xFFB30A

		// Act
		let actualHex = colorService.getPrimaryHex()

		// Assert
		XCTAssertEqual(actualHex, expectedHex)
    }

	func test_noSecondarySaved_returnsDefault() throws {
		// Arrange
		let expectedHex = 0xFBC118

		// Act
		let actualHex = colorService.getSecondaryHex()

		// Assert
		XCTAssertEqual(actualHex, expectedHex)
	}

	func test_noTertiarySaved_returnsDefault() throws {
		// Arrange
		let expectedHex = 0xFFFFCA

		// Act
		let actualHex = colorService.getTertiaryHex()

		// Assert
		XCTAssertEqual(actualHex, expectedHex)
	}

	func test_primarySaved_returnsSavedHex() throws {
		// Arrange
		let expectedHex = 0xFFFCCC
		let expectedColor = UIColor(netHex: expectedHex)

		// Act
		colorService.save(hex: expectedHex, name: Theme.Primary.rawValue)
		let actualHex = colorService.getPrimaryHex()
		let actualColor = colorService.getPrimaryColor()

		// Assert
		XCTAssertEqual(actualHex, expectedHex)
		XCTAssertEqual(actualColor, expectedColor)
	}

	func test_secondarySaved_returnsSavedHex() throws {
		// Arrange
		let expectedHex = 0xFFFAAA
		let expectedColor = UIColor(netHex: expectedHex)

		// Act
		colorService.save(hex: expectedHex, name: Theme.Secondary.rawValue)
		let actualHex = colorService.getSecondaryHex()
		let actualColor = colorService.getSecondaryColor()

		// Assert
		XCTAssertEqual(actualHex, expectedHex)
		XCTAssertEqual(actualColor, expectedColor)
	}

	func test_tertiarySaved_returnsSavedHex() throws {
		// Arrange
		let expectedHex = 0xFFFBBB
		let expectedColor = UIColor(netHex: expectedHex)

		// Act
		colorService.save(hex: expectedHex, name: Theme.Tertiary.rawValue)
		let actualHex = colorService.getTertiaryHex()
		let actualColor = colorService.getTertiaryColor()

		// Assert
		XCTAssertEqual(actualHex, expectedHex)
		XCTAssertEqual(actualColor, expectedColor)
	}
}
