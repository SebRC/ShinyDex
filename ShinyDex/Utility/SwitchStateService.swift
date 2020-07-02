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
	fileprivate var huntStateService = HuntStateService()
	
	func resolveShinyCharmSwitchState(generation: Int, shinyCharmSwitch: UISwitch)
	{
		if generation < 2
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
		if generation == 6
		{
			enableSwitch(uiSwitch: lureSwitch)
			lureSwitch.isOn = huntState.huntMethod == HuntMethod.Lure
		}
		else
		{
			disableSwitch(uiSwitch: lureSwitch)
		}
	}

	func resolveMasudaSwitchState(generation : Int, masudaSwitch: UISwitch)
	{
		if generation < 1 || generation == 6
		{
			disableSwitch(uiSwitch: masudaSwitch)
		}
		else
		{
			enableSwitch(uiSwitch: masudaSwitch)
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
