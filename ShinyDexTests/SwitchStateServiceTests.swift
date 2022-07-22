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
    
    fileprivate let gameHasMethodCases: [Games: HuntMethod] = [.Crystal: .Gen2Breeding, .SoulSilver: .Masuda, .Platinum: .Pokeradar, .X: .ChainFishing, .OmegaRuby: .DexNav, .Y: .FriendSafari, .UltraSun: .SosChaining, .LetsGoEevee: .Lure]

    func test_gameHasMethod_switchIsEnabled() throws {
		// Arrange
        let pokemon = Pokemon()
        
        for huntMethodCase in gameHasMethodCases {
            pokemon.game = huntMethodCase.key
            pokemon.huntMethod = huntMethodCase.value
            let huntMethodSwitch = UISwitch()
            huntMethodSwitch.isOn = false

            // Act
            switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: huntMethodSwitch, huntMethod: huntMethodCase.value)

            // Assert
            XCTAssertTrue(huntMethodSwitch.isOn)
            XCTAssertTrue(huntMethodSwitch.isEnabled)
        }
    }
    
    fileprivate let gameDoesNotHaveMethodCases: [Games: HuntMethod] = [.Ruby: .Gen2Breeding, .Crystal: .Masuda, .SoulSilver: .Pokeradar, .Sun: .ChainFishing, .Y: .DexNav, .AlphaSapphire: .FriendSafari, .Sword: .SosChaining, .Shield: .Lure]
    
    func test_gameDoesNotHaveMethod_switchIsDisabled() throws {
        // Arrange
        let pokemon = Pokemon()
        
        for huntMethodCase in gameDoesNotHaveMethodCases {
            pokemon.game = huntMethodCase.key
            pokemon.huntMethod = huntMethodCase.value
            let huntMethodSwitch = UISwitch()
            huntMethodSwitch.isOn = true

            // Act
            switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: huntMethodSwitch, huntMethod: huntMethodCase.value)

            // Assert
            XCTAssertFalse(huntMethodSwitch.isOn)
            XCTAssertFalse(huntMethodSwitch.isEnabled)
        }
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
}
