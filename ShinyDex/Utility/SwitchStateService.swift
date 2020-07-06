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
	func resolveGen2BreddingSwitchState(huntState: HuntState, gen2BreedingSwitch: UISwitch)
	{
		if huntState.generation == 0
		{
			enableSwitch(uiSwitch: gen2BreedingSwitch)
			gen2BreedingSwitch.isOn = huntState.huntMethod == .Gen2Breeding
		}
		else
		{
			disableSwitch(uiSwitch: gen2BreedingSwitch)
		}
	}
	
	func resolveShinyCharmSwitchState(huntState: HuntState, shinyCharmSwitch: UISwitch)
	{
		if huntState.generation < 2
		{
			disableSwitch(uiSwitch: shinyCharmSwitch)
			huntState.isShinyCharmActive = false
		}
		else
		{
			enableSwitch(uiSwitch: shinyCharmSwitch)
			shinyCharmSwitch.isOn = huntState.isShinyCharmActive
		}
	}

	func resolveFriendSafariSwitchState(huntState: HuntState, friendSafariSwitch: UISwitch)
	{
		if huntState.generation == 3
		{
			enableSwitch(uiSwitch: friendSafariSwitch)
			friendSafariSwitch.isOn = huntState.huntMethod == .FriendSafari
		}
		else
		{
			disableSwitch(uiSwitch: friendSafariSwitch)
		}
	}

	func resolveLureSwitchState(huntState: HuntState, lureSwitch: UISwitch)
	{
		if huntState.generation == 6
		{
			enableSwitch(uiSwitch: lureSwitch)
			lureSwitch.isOn = huntState.huntMethod == .Lure
		}
		else
		{
			disableSwitch(uiSwitch: lureSwitch)
		}
	}

	func resolveMasudaSwitchState(huntState: HuntState, masudaSwitch: UISwitch)
	{
		if huntState.generation < 1 || huntState.generation == 6
		{
			disableSwitch(uiSwitch: masudaSwitch)
		}
		else
		{
			enableSwitch(uiSwitch: masudaSwitch)
			masudaSwitch.isOn = huntState.huntMethod == .Masuda
		}
	}

	func resolveChainFishingSwitchState(huntState: HuntState, chainFishingSwitch: UISwitch)
	{
		if huntState.generation == 3
		{
			enableSwitch(uiSwitch: chainFishingSwitch)
			chainFishingSwitch.isOn = huntState.huntMethod == .ChainFishing
		}
		else
		{
			disableSwitch(uiSwitch: chainFishingSwitch)
		}
	}

	func resolveSosChainingSwitchState(huntState: HuntState, sosChainingSwitch: UISwitch)
	{
		if huntState.generation == 4
		{
			enableSwitch(uiSwitch: sosChainingSwitch)
			sosChainingSwitch.isOn = huntState.huntMethod == .SosChaining
		}
		else
		{
			disableSwitch(uiSwitch: sosChainingSwitch)
		}
	}

	func resolvePokeradarSwitchState(huntState: HuntState, pokeradarSwitch: UISwitch)
	{
		if huntState.generation == 1 || huntState.generation == 3
		{
			enableSwitch(uiSwitch: pokeradarSwitch)
			pokeradarSwitch.isOn = huntState.huntMethod == .Pokeradar
		}
		else
		{
			disableSwitch(uiSwitch: pokeradarSwitch)
		}
	}

	func resolveDexNavSwitchState(huntState: HuntState, dexNavSwitch: UISwitch)
	{
		if huntState.generation == 3
		{
			enableSwitch(uiSwitch: dexNavSwitch)
			dexNavSwitch.isOn = huntState.huntMethod == .DexNav
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
