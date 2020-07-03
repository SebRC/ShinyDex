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
		}
		else
		{
			enableSwitch(uiSwitch: shinyCharmSwitch)
			shinyCharmSwitch.isOn = huntState.isShinyCharmActive
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
