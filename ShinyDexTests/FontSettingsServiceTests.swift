import XCTest
import UIKit
@testable import ShinyDex

class FontSettingsServiceTests: XCTestCase {
	var fontSettingsService: FontSettingsService!

    override func setUpWithError() throws {
		try super.setUpWithError()
		fontSettingsService = FontSettingsService()
    }

    override func tearDownWithError() throws {
        fontSettingsService = nil
		try super.tearDownWithError()
    }

    func test_modernThemeXxSmallFont_returnsSystemFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Modern.description
		let expectedFont = UIFont.systemFont(ofSize: 12)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getXxSmallFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
    }

	func test_modernThemeExtraSmallFont_returnsSystemFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Modern.description
		let expectedFont = UIFont.systemFont(ofSize: 15)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getExtraSmallFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeSmallFont_returnsSystemFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Modern.description
		let expectedFont = UIFont.systemFont(ofSize: 17)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getSmallFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeMediumFont_returnsSystemFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Modern.description
		let expectedFont = UIFont.systemFont(ofSize: 20)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getMediumFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeLargeFont_returnsSystemFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Modern.description
		let expectedFont = UIFont.systemFont(ofSize: 22)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getLargeFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeExtraLargeFont_returnsSystemFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Modern.description
		let expectedFont = UIFont.systemFont(ofSize: 25)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getExtraLargeFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeXxLargeFont_returnsSystemFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Modern.description
		let expectedFont = UIFont.systemFont(ofSize: 27)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getXxLargeFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeXxSmallFont_returnsGameboyFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Retro.description
		let expectedFont = UIFont(name: FontName.PokemonGB.description, size: 7)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getXxSmallFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeExtraSmallFont_returnsGameboyFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Retro.description
		let expectedFont = UIFont(name: FontName.PokemonGB.description, size: 10)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getExtraSmallFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeSmallFont_returnsGameboyFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Retro.description
		let expectedFont = UIFont(name: FontName.PokemonGB.description, size: 12)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getSmallFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeMediumFont_returnsGameboyFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Retro.description
		let expectedFont = UIFont(name: FontName.PokemonGB.description, size: 15)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getMediumFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeLargeFont_returnsGameboyFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Retro.description
		let expectedFont = UIFont(name: FontName.PokemonGB.description, size: 17)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getLargeFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeExtraLargeFont_returnsGameboyFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Retro.description
		let expectedFont = UIFont(name: FontName.PokemonGB.description, size: 20)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getExtraLargeFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}

	func test_modernThemeXxLargeFont_returnsGameboyFont() throws {
		// Arrange
		let fontTheme = FontThemeName.Retro.description
		let expectedFont = UIFont(name: FontName.PokemonGB.description, size: 22)

		// Act
		fontSettingsService.save(fontThemeName: fontTheme)
		let actualFont = fontSettingsService.getXxLargeFont()

		// Assert
		XCTAssertEqual(actualFont, expectedFont)
	}
}
