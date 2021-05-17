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
		let entries = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hunts", 9: "Collection", 10: "Kanto", 1000: "Kanto", -1: "Kanto"]

		// Act + Assert
		for entry in entries {
			let actual = textResolver.getGenTitle(gen: entry.key)
			XCTAssertEqual(actual, entry.value)
		}
	}

	func test_withLgpeMaxChainNotReached_onlyComboTextIsShown() {
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

}
