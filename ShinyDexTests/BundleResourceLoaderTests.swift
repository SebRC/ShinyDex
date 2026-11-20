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
        let expectedList = ["poke", "none", "beast", "cherish", "dive", "dream", "dusk", "fast", "friend", "great",
        "heal", "heavy", "level", "love", "lure", "luxury", "master", "moon", "nest", "net", "park",
        "premier", "quick", "repeat", "safari", "sport", "timer", "ultra"]

        let actualList = resourceLoader.loadLines(ofTextResource: "pokeballs")

        XCTAssertEqual(actualList, expectedList)
    }
}
