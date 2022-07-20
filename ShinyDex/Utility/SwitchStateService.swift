import Foundation
import UIKit

class SwitchStateService {
    
	func resolveGen2BreddingSwitchState(pokemon: Pokemon, gen2BreedingSwitch: UISwitch)
	{
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.Gen2Breeding) ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: gen2BreedingSwitch)
			gen2BreedingSwitch.isOn = pokemon.huntMethod == .Gen2Breeding
		}
		else {
			disableSwitch(uiSwitch: gen2BreedingSwitch)
		}
	}
	
	func resolveShinyCharmSwitchState(pokemon: Pokemon, shinyCharmSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.isShinyCharmAvailable ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: shinyCharmSwitch)
			shinyCharmSwitch.isOn = pokemon.isShinyCharmActive
		}
		else {
			disableSwitch(uiSwitch: shinyCharmSwitch)
			pokemon.isShinyCharmActive = false
		}
	}

	func resolveFriendSafariSwitchState(pokemon: Pokemon, friendSafariSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.FriendSafari) ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: friendSafariSwitch)
			friendSafariSwitch.isOn = pokemon.huntMethod == .FriendSafari
		}
		else {
			disableSwitch(uiSwitch: friendSafariSwitch)
		}
	}

	func resolveLureSwitchState(pokemon: Pokemon, lureSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.Lure) ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: lureSwitch)
			lureSwitch.isOn = pokemon.huntMethod == .Lure
		}
		else {
			disableSwitch(uiSwitch: lureSwitch)
		}
	}

	func resolveMasudaSwitchState(pokemon: Pokemon, masudaSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.Masuda) ?? false
		if (switchEnabled) {
            enableSwitch(uiSwitch: masudaSwitch)
            masudaSwitch.isOn = pokemon.huntMethod == .Masuda
		}
		else {
            disableSwitch(uiSwitch: masudaSwitch)
		}
	}

	func resolveChainFishingSwitchState(pokemon: Pokemon, chainFishingSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.ChainFishing) ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: chainFishingSwitch)
			chainFishingSwitch.isOn = pokemon.huntMethod == .ChainFishing
		}
		else {
			disableSwitch(uiSwitch: chainFishingSwitch)
		}
	}

	func resolveSosChainingSwitchState(pokemon: Pokemon, sosChainingSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.SosChaining) ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: sosChainingSwitch)
			sosChainingSwitch.isOn = pokemon.huntMethod == .SosChaining
		}
		else {
			disableSwitch(uiSwitch: sosChainingSwitch)
		}
	}

	func resolvePokeradarSwitchState(pokemon: Pokemon, pokeradarSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.Pokeradar) ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: pokeradarSwitch)
			pokeradarSwitch.isOn = pokemon.huntMethod == .Pokeradar
		}
		else {
			disableSwitch(uiSwitch: pokeradarSwitch)
		}
	}

	func resolveDexNavSwitchState(pokemon: Pokemon, dexNavSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(HuntMethod.DexNav) ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: dexNavSwitch)
			dexNavSwitch.isOn = pokemon.huntMethod == .DexNav
		}
		else {
			disableSwitch(uiSwitch: dexNavSwitch)
		}
	}

	fileprivate func disableSwitch(uiSwitch: UISwitch) {
		uiSwitch.isOn = false
		uiSwitch.isEnabled = false
	}

	fileprivate func enableSwitch(uiSwitch: UISwitch) {
		uiSwitch.isEnabled = true
	}
}
