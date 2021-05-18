//
//  SwitchStateServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 18/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
import UIKit
@testable import ShinyDex

class SwitchStateServiceTests: XCTestCase {
	var switchStateService: SwitchStateService!

    override func setUpWithError() throws {
		try super.setUpWithError()
        switchStateService = SwitchStateService()
    }

    override func tearDownWithError() throws {
        switchStateService = nil
		try super.tearDownWithError()
    }

    func test_gen2BreedingOn_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		pokemon.huntMethod = .Gen2Breeding
		let gen2BreedingSwitch = UISwitch()
		gen2BreedingSwitch.isOn = false

		// Act
		switchStateService.resolveGen2BreddingSwitchState(pokemon: pokemon, gen2BreedingSwitch: gen2BreedingSwitch)

		// Assert
		XCTAssertTrue(gen2BreedingSwitch.isOn)
		XCTAssertTrue(gen2BreedingSwitch.isEnabled)
    }

	func test_generationIsNot2_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 4
		let gen2BreedingSwitch = UISwitch()
		gen2BreedingSwitch.isOn = true

		// Act
		switchStateService.resolveGen2BreddingSwitchState(pokemon: pokemon, gen2BreedingSwitch: gen2BreedingSwitch)

		// Assert
		XCTAssertTrue(!gen2BreedingSwitch.isOn)
		XCTAssertTrue(!gen2BreedingSwitch.isEnabled)
	}

	func test_generationHasShinyCharm_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 5
		pokemon.isShinyCharmActive = true
		let shinyCharmSwitch = UISwitch()
		shinyCharmSwitch.isOn = false

		// Act
		switchStateService.resolveShinyCharmSwitchState(pokemon: pokemon, shinyCharmSwitch: shinyCharmSwitch)

		// Assert
		XCTAssertTrue(shinyCharmSwitch.isOn)
		XCTAssertTrue(shinyCharmSwitch.isEnabled)
	}

	func test_generationDoesNotHaveShinyCharm_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let shinyCharmSwitch = UISwitch()
		shinyCharmSwitch.isOn = true

		// Act
		switchStateService.resolveShinyCharmSwitchState(pokemon: pokemon, shinyCharmSwitch: shinyCharmSwitch)

		// Assert
		XCTAssertTrue(!shinyCharmSwitch.isOn)
		XCTAssertTrue(!shinyCharmSwitch.isEnabled)
	}

	func test_generationHasFriendSafari_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 6
		pokemon.huntMethod = .FriendSafari
		let friendSafariSwitch = UISwitch()
		friendSafariSwitch.isOn = false

		// Act
		switchStateService.resolveFriendSafariSwitchState(pokemon: pokemon, friendSafariSwitch: friendSafariSwitch)

		// Assert
		XCTAssertTrue(friendSafariSwitch.isOn)
		XCTAssertTrue(friendSafariSwitch.isEnabled)
	}

	func test_generationDoesNotHaveFriendSafari_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let friendSafariSwitch = UISwitch()
		friendSafariSwitch.isOn = true

		// Act
		switchStateService.resolveFriendSafariSwitchState(pokemon: pokemon, friendSafariSwitch: friendSafariSwitch)

		// Assert
		XCTAssertTrue(!friendSafariSwitch.isOn)
		XCTAssertTrue(!friendSafariSwitch.isEnabled)
	}

	func test_generationHasLures_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 0
		pokemon.huntMethod = .Lure
		let lureSwitch = UISwitch()
		lureSwitch.isOn = false

		// Act
		switchStateService.resolveLureSwitchState(pokemon: pokemon, lureSwitch: lureSwitch)

		// Assert
		XCTAssertTrue(lureSwitch.isOn)
		XCTAssertTrue(lureSwitch.isEnabled)
	}

	func test_generationDoesNotHaveLures_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let lureSwitch = UISwitch()
		lureSwitch.isOn = true

		// Act
		switchStateService.resolveLureSwitchState(pokemon: pokemon, lureSwitch: lureSwitch)

		// Assert
		XCTAssertTrue(!lureSwitch.isOn)
		XCTAssertTrue(!lureSwitch.isEnabled)
	}

	func test_generationHasMasuda_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 4
		pokemon.huntMethod = .Masuda
		let masudaSwitch = UISwitch()
		masudaSwitch.isOn = false

		// Act
		switchStateService.resolveMasudaSwitchState(pokemon: pokemon, masudaSwitch: masudaSwitch)

		// Assert
		XCTAssertTrue(masudaSwitch.isOn)
		XCTAssertTrue(masudaSwitch.isEnabled)
	}

	func test_generationDoesNotHaveMasuda_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let masudaSwitch = UISwitch()
		masudaSwitch.isOn = true

		// Act
		switchStateService.resolveMasudaSwitchState(pokemon: pokemon, masudaSwitch: masudaSwitch)

		// Assert
		XCTAssertTrue(!masudaSwitch.isOn)
		XCTAssertTrue(!masudaSwitch.isEnabled)
	}

	func test_generationHasChainFishing_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 6
		pokemon.huntMethod = .ChainFishing
		let chainFishingSwitch = UISwitch()
		chainFishingSwitch.isOn = false

		// Act
		switchStateService.resolveChainFishingSwitchState(pokemon: pokemon, chainFishingSwitch: chainFishingSwitch)

		// Assert
		XCTAssertTrue(chainFishingSwitch.isOn)
		XCTAssertTrue(chainFishingSwitch.isEnabled)
	}

	func test_generationDoesNotHaveChainFishing_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let chainFishingSwitch = UISwitch()
		chainFishingSwitch.isOn = true

		// Act
		switchStateService.resolveChainFishingSwitchState(pokemon: pokemon, chainFishingSwitch: chainFishingSwitch)

		// Assert
		XCTAssertTrue(!chainFishingSwitch.isOn)
		XCTAssertTrue(!chainFishingSwitch.isEnabled)
	}

	func test_generationHasSosChaining_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 7
		pokemon.huntMethod = .SosChaining
		let sosChainingSwitch = UISwitch()
		sosChainingSwitch.isOn = false

		// Act
		switchStateService.resolveSosChainingSwitchState(pokemon: pokemon, sosChainingSwitch: sosChainingSwitch)

		// Assert
		XCTAssertTrue(sosChainingSwitch.isOn)
		XCTAssertTrue(sosChainingSwitch.isEnabled)
	}

	func test_generationDoesNotHaveSosChaining_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let sosChainingSwitch = UISwitch()
		sosChainingSwitch.isOn = true

		// Act
		switchStateService.resolveSosChainingSwitchState(pokemon: pokemon, sosChainingSwitch: sosChainingSwitch)

		// Assert
		XCTAssertTrue(!sosChainingSwitch.isOn)
		XCTAssertTrue(!sosChainingSwitch.isEnabled)
	}

	func test_generationHasPokeradar_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 4
		pokemon.huntMethod = .Pokeradar
		let pokeradarSwitch = UISwitch()
		pokeradarSwitch.isOn = false

		// Act
		switchStateService.resolvePokeradarSwitchState(pokemon: pokemon, pokeradarSwitch: pokeradarSwitch)

		// Assert
		XCTAssertTrue(pokeradarSwitch.isOn)
		XCTAssertTrue(pokeradarSwitch.isEnabled)
	}

	func test_generationDoesNotHavePokeradar_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let pokeradarSwitch = UISwitch()
		pokeradarSwitch.isOn = true

		// Act
		switchStateService.resolvePokeradarSwitchState(pokemon: pokemon, pokeradarSwitch: pokeradarSwitch)

		// Assert
		XCTAssertTrue(!pokeradarSwitch.isOn)
		XCTAssertTrue(!pokeradarSwitch.isEnabled)
	}

	func test_generationHasDexNav_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 6
		pokemon.huntMethod = .DexNav
		let dexNavSwitch = UISwitch()
		dexNavSwitch.isOn = false

		// Act
		switchStateService.resolveDexNavSwitchState(pokemon: pokemon, dexNavSwitch: dexNavSwitch)

		// Assert
		XCTAssertTrue(dexNavSwitch.isOn)
		XCTAssertTrue(dexNavSwitch.isEnabled)
	}

	func test_generationDoesNotHaveDexNav_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
		let dexNavSwitch = UISwitch()
		dexNavSwitch.isOn = true

		// Act
		switchStateService.resolveDexNavSwitchState(pokemon: pokemon, dexNavSwitch: dexNavSwitch)

		// Assert
		XCTAssertTrue(!dexNavSwitch.isOn)
		XCTAssertTrue(!dexNavSwitch.isEnabled)
	}
}
