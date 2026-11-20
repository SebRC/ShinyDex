import XCTest
@testable import ShinyDex

class ProbabilityServiceTests: XCTestCase {
    var probabilityService: ProbabilityService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        probabilityService = ProbabilityService()
    }

    override func tearDownWithError() throws {
        probabilityService = nil
        try super.tearDownWithError()
    }

    func test_normalOdds_returnsWithReasonableAccuracy() {
        // Arrange
        let entries = [756: 8.82, 14017: 81.93, 1849: 20.21, 2318: 24.65, 1000000: 100.0]

        // Act + Assert
        for entry in entries {
            let actualProbability = probabilityService.getProbability(encounters: entry.key, shinyOdds: 8192)
            XCTAssertEqual(actualProbability, entry.value, accuracy: 0.01)
        }
    }

    func test_differentMethodsBelowDecrement_returnsChainText() {
        // Arrange
        let entries = [HuntMethod.Lure: 30, HuntMethod.Pokeradar: 40,
                       HuntMethod.ChainFishing: 20, HuntMethod.SosChaining: 30]

        // Act + Assert
        for entry in entries {
            let pokemon = PokemonFixture()
            pokemon.huntMethod = entry.key
            pokemon.encounters = 0
            let actualText = TextResolver().getProbabilityText(pokemon: pokemon.makeDetails(chainThreshold: entry.value, probability: 0.0))
            XCTAssertEqual(actualText, "Chain \(entry.value) to see probability")
        }
    }

    func test_generationIs0_returnsChainText() {
        // Arrange
        let methodDecrement = 30
        let pokemon = PokemonFixture()
        pokemon.huntMethod = .Encounters
        pokemon.generation = 0
        pokemon.encounters = 0

        // Act
        let actualText = TextResolver().getProbabilityText(pokemon: pokemon.makeDetails(chainThreshold: methodDecrement, probability: 0.0))

        // Assert
        XCTAssertEqual(actualText, "Chain \(methodDecrement) to see probability")
    }

    func test_differentMethodsAboveDecrement_returnsProbabilityText() {
        // Arrange
        let probability = 88.32
        let entries = [HuntMethod.Lure: 30, HuntMethod.Pokeradar: 40,
                       HuntMethod.ChainFishing: 20, HuntMethod.SosChaining: 30]

        // Act + Assert
        for entry in entries {
            let pokemon = PokemonFixture()
            pokemon.huntMethod = entry.key
            pokemon.encounters = 50
            let actualText = TextResolver().getProbabilityText(pokemon: pokemon.makeDetails(chainThreshold: entry.value, probability: probability))
            XCTAssertEqual(actualText, "Probability: \(probability)")
        }
    }

    func test_dexNavBelowDecrement_returnsSearchLevelText() {
        // Arrange
        let pokemon = PokemonFixture()
        pokemon.huntMethod = .DexNav
        pokemon.encounters = 50

        // Act
        let actualText = TextResolver().getProbabilityText(pokemon: pokemon.makeDetails(chainThreshold: 999, probability: 0.00))

        // Assert
        XCTAssertEqual(actualText, "Reach Search level 999 to see probability")
    }
}
