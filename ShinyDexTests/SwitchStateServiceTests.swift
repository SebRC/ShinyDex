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

    func test_gameHasGen2Breeding_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
        pokemon.game = .Crystal
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

	func test_gameDoesNotHaveGen2Breeding_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 4
        pokemon.game = .SoulSilver
		let gen2BreedingSwitch = UISwitch()
		gen2BreedingSwitch.isOn = true

		// Act
		switchStateService.resolveGen2BreddingSwitchState(pokemon: pokemon, gen2BreedingSwitch: gen2BreedingSwitch)

		// Assert
		XCTAssertFalse(gen2BreedingSwitch.isOn)
		XCTAssertFalse(gen2BreedingSwitch.isEnabled)
	}

	func test_gameHasShinyCharm_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 5
        pokemon.game = .Black2
        pokemon.isShinyCharmActive = true
		let shinyCharmSwitch = UISwitch()
		shinyCharmSwitch.isOn = false

		// Act
		switchStateService.resolveShinyCharmSwitchState(pokemon: pokemon, shinyCharmSwitch: shinyCharmSwitch)

		// Assert
		XCTAssertTrue(shinyCharmSwitch.isOn)
		XCTAssertTrue(shinyCharmSwitch.isEnabled)
	}

	func test_gameDoesNotHaveShinyCharm_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
        pokemon.game = .Gold
		let shinyCharmSwitch = UISwitch()
		shinyCharmSwitch.isOn = true

		// Act
		switchStateService.resolveShinyCharmSwitchState(pokemon: pokemon, shinyCharmSwitch: shinyCharmSwitch)

		// Assert
		XCTAssertFalse(shinyCharmSwitch.isOn)
		XCTAssertFalse(shinyCharmSwitch.isEnabled)
	}

	func test_gameHasFriendSafari_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 6
        pokemon.game = .X
        pokemon.huntMethod = .FriendSafari
		let friendSafariSwitch = UISwitch()
		friendSafariSwitch.isOn = false

		// Act
		switchStateService.resolveFriendSafariSwitchState(pokemon: pokemon, friendSafariSwitch: friendSafariSwitch)

		// Assert
		XCTAssertTrue(friendSafariSwitch.isOn)
		XCTAssertTrue(friendSafariSwitch.isEnabled)
	}

	func test_gameDoesNotHaveFriendSafari_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
        pokemon.game = .Silver
		let friendSafariSwitch = UISwitch()
		friendSafariSwitch.isOn = true

		// Act
		switchStateService.resolveFriendSafariSwitchState(pokemon: pokemon, friendSafariSwitch: friendSafariSwitch)

		// Assert
		XCTAssertFalse(friendSafariSwitch.isOn)
		XCTAssertFalse(friendSafariSwitch.isEnabled)
	}

	func test_gameHasLures_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 7
        pokemon.game = .LetsGoPikachu
        pokemon.huntMethod = .Lure
		let lureSwitch = UISwitch()
		lureSwitch.isOn = false

		// Act
		switchStateService.resolveLureSwitchState(pokemon: pokemon, lureSwitch: lureSwitch)

		// Assert
		XCTAssertTrue(lureSwitch.isOn)
		XCTAssertTrue(lureSwitch.isEnabled)
	}

	func test_gameDoesNotHaveLures_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
        pokemon.game = .Gold
		let lureSwitch = UISwitch()
		lureSwitch.isOn = true

		// Act
		switchStateService.resolveLureSwitchState(pokemon: pokemon, lureSwitch: lureSwitch)

		// Assert
		XCTAssertFalse(lureSwitch.isOn)
		XCTAssertFalse(lureSwitch.isEnabled)
	}

	func test_gameHasMasuda_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 4
        pokemon.game = .Platinum
        pokemon.huntMethod = .Masuda
		let masudaSwitch = UISwitch()
		masudaSwitch.isOn = false

		// Act
		switchStateService.resolveMasudaSwitchState(pokemon: pokemon, masudaSwitch: masudaSwitch)

		// Assert
		XCTAssertTrue(masudaSwitch.isOn)
		XCTAssertTrue(masudaSwitch.isEnabled)
	}

	func test_gameDoesNotHaveMasuda_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 2
        pokemon.game = .Crystal
		let masudaSwitch = UISwitch()
		masudaSwitch.isOn = true

		// Act
		switchStateService.resolveMasudaSwitchState(pokemon: pokemon, masudaSwitch: masudaSwitch)

		// Assert
		XCTAssertFalse(masudaSwitch.isOn)
		XCTAssertFalse(masudaSwitch.isEnabled)
	}

	func test_gameHasChainFishing_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 6
        pokemon.game = .OmegaRuby
        pokemon.huntMethod = .ChainFishing
		let chainFishingSwitch = UISwitch()
		chainFishingSwitch.isOn = false

		// Act
		switchStateService.resolveChainFishingSwitchState(pokemon: pokemon, chainFishingSwitch: chainFishingSwitch)

		// Assert
		XCTAssertTrue(chainFishingSwitch.isOn)
		XCTAssertTrue(chainFishingSwitch.isEnabled)
	}

	func test_gameDoesNotHaveChainFishing_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 8
        pokemon.game = .Sword
		let chainFishingSwitch = UISwitch()
		chainFishingSwitch.isOn = true

		// Act
		switchStateService.resolveChainFishingSwitchState(pokemon: pokemon, chainFishingSwitch: chainFishingSwitch)

		// Assert
		XCTAssertFalse(chainFishingSwitch.isOn)
		XCTAssertFalse(chainFishingSwitch.isEnabled)
	}

	func test_gameHasSosChaining_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 7
        pokemon.game = .UltraSun
        pokemon.huntMethod = .SosChaining
		let sosChainingSwitch = UISwitch()
		sosChainingSwitch.isOn = false

		// Act
		switchStateService.resolveSosChainingSwitchState(pokemon: pokemon, sosChainingSwitch: sosChainingSwitch)

		// Assert
		XCTAssertTrue(sosChainingSwitch.isOn)
		XCTAssertTrue(sosChainingSwitch.isEnabled)
	}

	func test_gameDoesNotHaveSosChaining_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 6
        pokemon.game = .AlphaSapphire
		let sosChainingSwitch = UISwitch()
		sosChainingSwitch.isOn = true

		// Act
		switchStateService.resolveSosChainingSwitchState(pokemon: pokemon, sosChainingSwitch: sosChainingSwitch)

		// Assert
		XCTAssertFalse(sosChainingSwitch.isOn)
		XCTAssertFalse(sosChainingSwitch.isEnabled)
	}

	func test_gameHasPokeradar_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 4
        pokemon.game = .Pearl
        pokemon.huntMethod = .Pokeradar
		let pokeradarSwitch = UISwitch()
		pokeradarSwitch.isOn = false

		// Act
		switchStateService.resolvePokeradarSwitchState(pokemon: pokemon, pokeradarSwitch: pokeradarSwitch)

		// Assert
		XCTAssertTrue(pokeradarSwitch.isOn)
		XCTAssertTrue(pokeradarSwitch.isEnabled)
	}

	func test_gameDoesNotHavePokeradar_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 5
        pokemon.game = .Black2
		let pokeradarSwitch = UISwitch()
		pokeradarSwitch.isOn = true

		// Act
		switchStateService.resolvePokeradarSwitchState(pokemon: pokemon, pokeradarSwitch: pokeradarSwitch)

		// Assert
		XCTAssertFalse(pokeradarSwitch.isOn)
		XCTAssertFalse(pokeradarSwitch.isEnabled)
	}

	func test_gameHasDexNav_switchIsEnabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 6
        pokemon.game = .AlphaSapphire
        pokemon.huntMethod = .DexNav
		let dexNavSwitch = UISwitch()
		dexNavSwitch.isOn = false

		// Act
		switchStateService.resolveDexNavSwitchState(pokemon: pokemon, dexNavSwitch: dexNavSwitch)

		// Assert
		XCTAssertTrue(dexNavSwitch.isOn)
		XCTAssertTrue(dexNavSwitch.isEnabled)
	}

	func test_gameDoesNotHaveDexNav_switchIsDisabled() throws {
		// Arrange
		let pokemon = Pokemon()
		pokemon.generation = 7
        pokemon.game = .Sun
		let dexNavSwitch = UISwitch()
		dexNavSwitch.isOn = true

		// Act
		switchStateService.resolveDexNavSwitchState(pokemon: pokemon, dexNavSwitch: dexNavSwitch)

		// Assert
		XCTAssertFalse(dexNavSwitch.isOn)
		XCTAssertFalse(dexNavSwitch.isEnabled)
	}
}
