import XCTest
@testable import ShinyDex

class BundleResourceLoaderTests: XCTestCase {
	var resourceLoader: BundleResourceLoader!

    override func setUpWithError() throws {
		try super.setUpWithError()
		resourceLoader = BundleResourceLoader(bundle: Bundle(for: AppDelegate.self))
    }

    override func tearDownWithError() throws {
        resourceLoader = nil
		try super.tearDownWithError()
    }

    func test_pokeballText_returnsListOfPokeballs() throws {
		// Arrange
		let expectedList = ["poke", "none", "beast", "cherish", "dive", "dream", "dusk", "fast", "friend", "great",
		"heal", "heavy", "level", "love", "lure", "luxury", "master", "moon", "nest", "net", "park",
		"premier", "quick", "repeat", "safari", "sport", "timer", "ultra"]

		// Act
		let actualList = resourceLoader.lines(ofTextResource: "pokeballs")

		// Assert
		XCTAssertEqual(actualList, expectedList)
    }
}
