//
//  TextResolverTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 17/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class TextResolverTests: XCTestCase {

	var textResolver: TextResolver!

	override func setUpWithError() throws {
		try super.setUpWithError()
		textResolver = TextResolver()
	}

	override func tearDownWithError() throws {
		textResolver = nil
		try super.tearDownWithError()
	}


	func test_differentGenerations_returnsCorrectTitles() {
		// Arrange
		let notFoundText = "Not found"
        let entries = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hunts", 9: "Collection", 10: "PP Counter", 11: notFoundText, 1000: notFoundText, -1: notFoundText]

		// Act + Assert
		for entry in entries {
			let actual = textResolver.getGenTitle(gen: entry.key)
			XCTAssertEqual(actual, entry.value)
		}
	}

	func test_withLgpeMaxChainNotReached_onlyShowsMethodVerb() {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 0
		pokemon.encounters = 20
		let expectedResult = " Catch Combo: \(pokemon.encounters)"

		// Act
		let actual = textResolver.getEncountersLabelText(pokemon: pokemon)

		// Assert
		XCTAssertEqual(actual, expectedResult)
	}

	func test_withLgpeMaxChainReached_textIncludesSeen() {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 0
		pokemon.encounters = 35
		let methodDecrement = 5
		pokemon.huntMethod = .Lure
		let expectedResult = " Catch Combo: \(methodDecrement) + \(pokemon.encounters - methodDecrement) seen"

		// Act
		let actual = textResolver.getEncountersLabelText(pokemon: pokemon, methodDecrement: methodDecrement)

		// Assert
		XCTAssertEqual(actual, expectedResult)
	}

	func test_Gen2BreedingOrMasuda_textIncludesEggs() {
		// Arrange
		let encounters = 35
		let gen2BreddingPokemon = Pokemon()
		gen2BreddingPokemon.generation = 4
		gen2BreddingPokemon.encounters = encounters
		gen2BreddingPokemon.huntMethod = .Gen2Breeding

		let masudaPokemon = Pokemon()
		masudaPokemon.generation = 4
		masudaPokemon.encounters = encounters
		masudaPokemon.huntMethod = .Masuda
		let expectedResult = " Eggs: \(encounters)"

		// Act
		let gen2BreedingActual = textResolver.getEncountersLabelText(pokemon: gen2BreddingPokemon)
		let masudaActual = textResolver.getEncountersLabelText(pokemon: masudaPokemon)

		// Assert
		XCTAssertEqual(gen2BreedingActual, expectedResult)
		XCTAssertEqual(masudaActual, expectedResult)
	}

	func test_ChainingMaxChainNotReached_onlyShowsMethodVerb() {
		// Arrange
		let encounters = 15
		let sosChainPokemon = Pokemon()
		sosChainPokemon.generation = 7
		sosChainPokemon.encounters = encounters
		sosChainPokemon.huntMethod = .SosChaining

		let chainFishPokemon = Pokemon()
		chainFishPokemon.generation = 6
		chainFishPokemon.encounters = encounters
		chainFishPokemon.huntMethod = .ChainFishing
		let expectedResult = " Chain: \(encounters)"

		// Act
		let sosChainActual = textResolver.getEncountersLabelText(pokemon: sosChainPokemon)
		let chainFishActual = textResolver.getEncountersLabelText(pokemon: chainFishPokemon)

		// Assert
		XCTAssertEqual(sosChainActual, expectedResult)
		XCTAssertEqual(chainFishActual, expectedResult)
	}

	func test_ChainingMaxChainReached_textIncludesSeen() {
		// Arrange
		let encounters = 50
		let methodDecrement = 10
		let sosChainPokemon = Pokemon()
		sosChainPokemon.generation = 7
		sosChainPokemon.encounters = encounters
		sosChainPokemon.huntMethod = .SosChaining

		let chainFishPokemon = Pokemon()
		chainFishPokemon.generation = 6
		chainFishPokemon.encounters = encounters
		chainFishPokemon.huntMethod = .ChainFishing
		let expectedResult = " Chain: \(methodDecrement) + \(encounters - methodDecrement) seen"

		// Act
		let sosChainActual = textResolver.getEncountersLabelText(pokemon: sosChainPokemon, methodDecrement: methodDecrement)
		let chainFishActual = textResolver.getEncountersLabelText(pokemon: chainFishPokemon, methodDecrement: methodDecrement)

		// Assert
		XCTAssertEqual(sosChainActual, expectedResult)
		XCTAssertEqual(chainFishActual, expectedResult)
	}

	func test_PokeradarMaxChainReached_textIncludesPatches() {
		// Arrange
		let encounters = 50
		let methodDecrement = 10

		let pokeradarPokemon = Pokemon()
		pokeradarPokemon.generation = 6
		pokeradarPokemon.encounters = encounters
		pokeradarPokemon.huntMethod = .Pokeradar
		let expectedResult = " Chain: \(methodDecrement) + \(encounters - methodDecrement) patches"

		// Act
		let pokeradarActual = textResolver.getEncountersLabelText(pokemon: pokeradarPokemon, methodDecrement: methodDecrement)

		// Assert
		XCTAssertEqual(pokeradarActual, expectedResult)
	}

	func test_dexNavMaxChainNotReached_onlyShowsMethodVerb() {
		// Arrange
		let dexNavPokemon = Pokemon()
		dexNavPokemon.generation = 6
		dexNavPokemon.encounters = 50
		dexNavPokemon.huntMethod = .DexNav
		let expectedResult = " Search level: \(dexNavPokemon.encounters)"

		// Act
		let dexNavActual = textResolver.getEncountersLabelText(pokemon: dexNavPokemon)

		// Assert
		XCTAssertEqual(dexNavActual, expectedResult)
	}

	func test_dexNavMaxChainReached_textIncludesPatches() {
		// Arrange
		let methodDecrement = 10
		let dexNavPokemon = Pokemon()
		dexNavPokemon.generation = 6
		dexNavPokemon.encounters = 1000
		dexNavPokemon.huntMethod = .DexNav
		let expectedResult = " Search level: \(methodDecrement) + \(dexNavPokemon.encounters - methodDecrement) seen"

		// Act
		let dexNavActual = textResolver.getEncountersLabelText(pokemon: dexNavPokemon, methodDecrement: methodDecrement)

		// Assert
		XCTAssertEqual(dexNavActual, expectedResult)
	}

	func test_EncountersMethod_defaultText() {
		// Arrange
		let methodDecrement = 10
		let pokemon = Pokemon()
		pokemon.generation = 6
		pokemon.encounters = 1000
		pokemon.huntMethod = .Encounters
		let expectedResult = " Encounters: \(pokemon.encounters)"

		// Act
		let actual = textResolver.getEncountersLabelText(pokemon: pokemon, methodDecrement: methodDecrement)

		// Assert
		XCTAssertEqual(actual, expectedResult)
	}
}
