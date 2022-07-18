import XCTest
@testable import ShinyDex

class LocationUrlServiceTests: XCTestCase {

	var locationUrlService: LocationUrlService!

    override func setUpWithError() throws {
		try super.setUpWithError()
        locationUrlService = LocationUrlService()

    }

    override func tearDownWithError() throws {
        locationUrlService = nil
		try super.tearDownWithError()
    }


    func test_validGeneration_returns() {
        // Arrange
		let expected = "https://serebii.net/pokedex-dp/093.shtml"
		let pokemon = Pokemon()
		pokemon.number = 92
		pokemon.name = "Gastly"
		pokemon.generation = 4

		// Act
		let actual = locationUrlService.getUrl(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actual, expected)
    }

	func test_pokemonNotInGeneration_returnsEarliestPossibleGeneration() {
		// Arrange
		let expected = "https://serebii.net/pokedex-bw/496.shtml"
		let pokemon = Pokemon()
		pokemon.number = 495
		pokemon.name = "Snivy"
		pokemon.generation = 1

		// Act
		let actual = locationUrlService.getUrl(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actual, expected)
	}

	func test_generationIs8_pokemonNameIsPartoFUrl() {
		// Arrange
		let expected = "https://serebii.net/pokedex-swsh/charmander"
		let pokemon = Pokemon()
		pokemon.number = 5
		pokemon.name = "Charmander"
		pokemon.generation = 8

		// Act
		let actual = locationUrlService.getUrl(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actual, expected)
	}

	func test_invalidDexNumber_returnsDefaultGeneration() {
		// Arrange
		let expected = "https://serebii.net/pokedex-sm/1001.shtml"
		let pokemon = Pokemon()
		pokemon.number = 1000
		pokemon.name = "Charmander"
		pokemon.generation = 5

		// Act
		let actual = locationUrlService.getUrl(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actual, expected)
	}
}
