//
//  SwitchStateService.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 06/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class SwitchStateService
{
	func resolveGen2BreddingSwitchState(pokemon: Pokemon, gen2BreedingSwitch: UISwitch)
	{
		if pokemon.generation == 0
		{
			enableSwitch(uiSwitch: gen2BreedingSwitch)
			gen2BreedingSwitch.isOn = pokemon.huntMethod == .Gen2Breeding
		}
		else
		{
			disableSwitch(uiSwitch: gen2BreedingSwitch)
		}
	}
	
	func resolveShinyCharmSwitchState(pokemon: Pokemon, shinyCharmSwitch: UISwitch)
	{
		if pokemon.generation < 2
		{
			disableSwitch(uiSwitch: shinyCharmSwitch)
			pokemon.isShinyCharmActive = false
		}
		else
		{
			enableSwitch(uiSwitch: shinyCharmSwitch)
			shinyCharmSwitch.isOn = pokemon.isShinyCharmActive
		}
	}

	func resolveFriendSafariSwitchState(pokemon: Pokemon, friendSafariSwitch: UISwitch)
	{
		if pokemon.generation == 3
		{
			enableSwitch(uiSwitch: friendSafariSwitch)
			friendSafariSwitch.isOn = pokemon.huntMethod == .FriendSafari
		}
		else
		{
			disableSwitch(uiSwitch: friendSafariSwitch)
		}
	}

	func resolveLureSwitchState(pokemon: Pokemon, lureSwitch: UISwitch)
	{
		if pokemon.generation == 6
		{
			enableSwitch(uiSwitch: lureSwitch)
			lureSwitch.isOn = pokemon.huntMethod == .Lure
		}
		else
		{
			disableSwitch(uiSwitch: lureSwitch)
		}
	}

	func resolveMasudaSwitchState(pokemon: Pokemon, masudaSwitch: UISwitch)
	{
		if pokemon.generation < 1 || pokemon.generation == 6
		{
			disableSwitch(uiSwitch: masudaSwitch)
		}
		else
		{
			enableSwitch(uiSwitch: masudaSwitch)
			masudaSwitch.isOn = pokemon.huntMethod == .Masuda
		}
	}

	func resolveChainFishingSwitchState(pokemon: Pokemon, chainFishingSwitch: UISwitch)
	{
		if pokemon.generation == 3
		{
			enableSwitch(uiSwitch: chainFishingSwitch)
			chainFishingSwitch.isOn = pokemon.huntMethod == .ChainFishing
		}
		else
		{
			disableSwitch(uiSwitch: chainFishingSwitch)
		}
	}

	func resolveSosChainingSwitchState(pokemon: Pokemon, sosChainingSwitch: UISwitch)
	{
		if pokemon.generation == 4
		{
			enableSwitch(uiSwitch: sosChainingSwitch)
			sosChainingSwitch.isOn = pokemon.huntMethod == .SosChaining
		}
		else
		{
			disableSwitch(uiSwitch: sosChainingSwitch)
		}
	}

	func resolvePokeradarSwitchState(pokemon: Pokemon, pokeradarSwitch: UISwitch)
	{
		if pokemon.generation == 1 || pokemon.generation == 3
		{
			enableSwitch(uiSwitch: pokeradarSwitch)
			pokeradarSwitch.isOn = pokemon.huntMethod == .Pokeradar
		}
		else
		{
			disableSwitch(uiSwitch: pokeradarSwitch)
		}
	}

	func resolveDexNavSwitchState(pokemon: Pokemon, dexNavSwitch: UISwitch)
	{
		if pokemon.generation == 3
		{
			enableSwitch(uiSwitch: dexNavSwitch)
			dexNavSwitch.isOn = pokemon.huntMethod == .DexNav
		}
		else
		{
			disableSwitch(uiSwitch: dexNavSwitch)
		}
	}

	fileprivate func disableSwitch(uiSwitch: UISwitch)
	{
		uiSwitch.isOn = false
		uiSwitch.isEnabled = false
	}

	fileprivate func enableSwitch(uiSwitch: UISwitch)
	{
		uiSwitch.isEnabled = true
	}
}
