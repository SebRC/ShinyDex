//
//  PokemonServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 28/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

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
		var oldPokemon = cacheOldValues(pokemon: pokemon)
		pokemon.encounters = 50
		pokemon.caughtBall = "poke"
		pokemon.caughtDescription = "Caught"
		pokemon.generation = 4
		pokemon.huntMethod = .Pokeradar
		pokemon.increment = 4
		pokemon.isBeingHunted = true
		pokemon.isShinyCharmActive = true
		print(oldPokemon.encounters)
		print(oldPokemon.isBeingHunted)

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
		pokemonService.save(pokemon: pokemonToUpdate)
	}
}
