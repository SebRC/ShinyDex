////
////  OddsResolver.swift
////  ShinyDexPrototype
////
////  Created by Sebastian Christiansen on 06/12/2019.
////  Copyright © 2019 Sebastian Christiansen. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class OddsResolver
//{
//	var settingsRepo = SettingsRepository.settingsRepoSingleton
//	
//	func resolveShinyCharmSwitchState(generation: Int, shinyCharmSwitch: UISwitch)
//	{
//		let isPreGeneration5 = generation >= 0 && generation <= 3
//		
//		if isPreGeneration5
//		{
//			disableShinyCharmSwitch(shinyCharmSwitch: shinyCharmSwitch)
//		}
//		else
//		{
//			enableShinyCharmSwitch(shinyCharmSwitch: shinyCharmSwitch)
//		}
//	}
//	
//	fileprivate func disableShinyCharmSwitch(shinyCharmSwitch: UISwitch)
//	{
//		shinyCharmSwitch.isOn = false
//		shinyCharmSwitch.isEnabled = false
//	}
//	
//	fileprivate func enableShinyCharmSwitch(shinyCharmSwitch: UISwitch)
//	{
//		shinyCharmSwitch.isEnabled = true
//	}
//}
