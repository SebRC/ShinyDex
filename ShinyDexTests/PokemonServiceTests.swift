import XCTest
@testable import ShinyDex

class PokemonServiceTests: XCTestCase {
	var pokemonService: PokemonService!

    override func setUpWithError() throws {
		try super.setUpWithError()
		pokemonService = PokemonService()
    }

    override func tearDownWithError() throws {
		pokemonService = nil
		try super.tearDownWithError()
    }

    func test_savePokemon_valuesAreSaved() throws {
		// Arrange
		let allPokemon = pokemonService.getAll()
		let pokemon = allPokemon[0]
		let oldPokemon = cacheOldValues(pokemon: pokemon)
		pokemon.encounters = 50
		pokemon.caughtBall = "poke"
		pokemon.caughtDescription = "Caught"
		pokemon.generation = 4
		pokemon.huntMethod = .Pokeradar
		pokemon.increment = 4
		pokemon.isBeingHunted = true
		pokemon.isShinyCharmActive = true
        pokemon.game = Games.SoulSilver

		// Act
		pokemonService.save(pokemon: pokemon)
		let updatedPokemon = pokemonService.getAll()[0]

		// Assert
		XCTAssertEqual(updatedPokemon.encounters, 50)
		XCTAssertEqual(updatedPokemon.caughtBall, "poke")
		XCTAssertEqual(updatedPokemon.caughtDescription, "Caught")
		XCTAssertEqual(updatedPokemon.generation, 4)
		XCTAssertEqual(updatedPokemon.huntMethod, .Pokeradar)
		XCTAssertEqual(updatedPokemon.increment, 4)
		XCTAssertTrue(updatedPokemon.isBeingHunted)
		XCTAssertTrue(updatedPokemon.isShinyCharmActive)
        XCTAssertEqual(updatedPokemon.game, Games.SoulSilver)
		restoreValues(oldPokemon: oldPokemon, pokemonToUpdate: updatedPokemon)
    }

	fileprivate func cacheOldValues(pokemon: Pokemon) -> Pokemon {
		let cachedPokemon = Pokemon()
		cachedPokemon.encounters = pokemon.encounters
		cachedPokemon.caughtBall = pokemon.caughtBall
		cachedPokemon.caughtDescription = pokemon.caughtDescription
		cachedPokemon.generation = pokemon.generation
		cachedPokemon.huntMethod = pokemon.huntMethod
		cachedPokemon.increment = pokemon.increment
		cachedPokemon.isBeingHunted = pokemon.isBeingHunted
		cachedPokemon.isShinyCharmActive = pokemon.isShinyCharmActive
        cachedPokemon.game = pokemon.game
		return cachedPokemon
	}

	fileprivate func restoreValues(oldPokemon: Pokemon, pokemonToUpdate: Pokemon) {
		pokemonToUpdate.encounters = oldPokemon.encounters
		pokemonToUpdate.caughtBall = oldPokemon.caughtBall
		pokemonToUpdate.caughtDescription = oldPokemon.caughtDescription
		pokemonToUpdate.generation = oldPokemon.generation
		pokemonToUpdate.huntMethod = oldPokemon.huntMethod
		pokemonToUpdate.increment = oldPokemon.increment
		pokemonToUpdate.isBeingHunted = oldPokemon.isBeingHunted
		pokemonToUpdate.isShinyCharmActive = oldPokemon.isShinyCharmActive
        pokemonToUpdate.game = oldPokemon.game
		pokemonService.save(pokemon: pokemonToUpdate)
	}
}
