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
	var huntStateService = HuntStateService()
	
	func resolveShinyCharmSwitchState(generation: Int, shinyCharmSwitch: UISwitch)
	{
		let isPreGeneration5 = generation == 0

		if isPreGeneration5
		{
			disableSwitch(uiSwitch: shinyCharmSwitch)
		}
		else
		{
			enableSwitch(uiSwitch: shinyCharmSwitch)
		}
	}

	func resolveLureSwitchState(generation: Int, lureSwitch: UISwitch)
	{
		let huntState = huntStateService.get()
		if generation == 4
		{
			enableSwitch(uiSwitch: lureSwitch)
			lureSwitch.isOn = huntState.isLureInUse
		}
		else
		{
			disableSwitch(uiSwitch: lureSwitch)
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
