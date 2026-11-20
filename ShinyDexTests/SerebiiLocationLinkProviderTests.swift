import XCTest
@testable import ShinyDex

class SerebiiLocationLinkProviderTests: XCTestCase {

    var locationUrlService: SerebiiLocationLinkProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        locationUrlService = SerebiiLocationLinkProvider()
    }

    override func tearDownWithError() throws {
        locationUrlService = nil
        try super.tearDownWithError()
    }

    func test_validGeneration_returns() {
        let expected = "https://serebii.net/pokedex-dp/093.shtml"
        let (name, number, generation) = ("Gastly", 92, 4)

        let actual = locationUrlService.makeLocationURL(forPokemonNamed: name, number: number, generation: generation)

        XCTAssertEqual(actual, expected)
    }

    func test_pokemonNotInGeneration_returnsEarliestPossibleGeneration() {
        let expected = "https://serebii.net/pokedex-bw/496.shtml"
        let (name, number, generation) = ("Snivy", 495, 1)

        let actual = locationUrlService.makeLocationURL(forPokemonNamed: name, number: number, generation: generation)

        XCTAssertEqual(actual, expected)
    }

    func test_generationIs8_pokemonNameIsPartOfUrl() {
        let expected = "https://serebii.net/pokedex-swsh/charmander"
        let (name, number, generation) = ("Charmander", 5, 8)

        let actual = locationUrlService.makeLocationURL(forPokemonNamed: name, number: number, generation: generation)

        XCTAssertEqual(actual, expected)
    }

    func test_invalidDexNumber_returnsDefaultGeneration() {
        let expected = "https://serebii.net/pokedex-sm/2001.shtml"
        let (name, number, generation) = ("Charmander", 2000, 5)

        let actual = locationUrlService.makeLocationURL(forPokemonNamed: name, number: number, generation: generation)

        XCTAssertEqual(actual, expected)
    }
}
