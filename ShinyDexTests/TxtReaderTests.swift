import XCTest
@testable import ShinyDex

class TxtReaderTests: XCTestCase {
	var txtReader: TxtReader!

    override func setUpWithError() throws {
		try super.setUpWithError()
		txtReader = TxtReader()
    }

    override func tearDownWithError() throws {
        txtReader = nil
		try super.tearDownWithError()
    }

    func test_pokeballText_returnsListOfPokeballs() throws {
		// Arrange
		let expectedList = ["poke", "none", "beast", "cherish", "dive", "dream", "dusk", "fast", "friend", "great",
		"heal", "heavy", "level", "love", "lure", "luxury", "master", "moon", "nest", "net", "park",
		"premier", "quick", "repeat", "safari", "sport", "timer", "ultra"]

		// Act
		let actualList = txtReader.readFile(textFile: "pokeballs")

		// Assert
		XCTAssertEqual(actualList, expectedList)
    }
}
