//
//  OddsResolver.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 06/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class OddsResolver
{
	var settingsRepository = SettingsRepository.settingsRepositorySingleton
	
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
		if generation == 4
		{
			enableSwitch(uiSwitch: lureSwitch)
			lureSwitch.isOn = settingsRepository.isLureInUse
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

	func getLGPEProbability(catchCombo: Int, isShinyCharmActive: Bool, isLureInUse: Bool) -> Double
	{
		if catchCombo >= 0 && catchCombo <= 10
		{
			return getLGPETier4Probability(catchCombo: catchCombo, isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		else if catchCombo >= 11 && catchCombo <= 20
		{
			return getLGPETier3Probability(catchCombo: catchCombo, isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		else if catchCombo >= 21 && catchCombo <= 30
		{
			return getLGPETier2Probability(catchCombo: catchCombo, isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}

		return getLGPETier1Probability(catchCombo: catchCombo, isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
	}

	fileprivate func getLGPETier4Probability(catchCombo: Int, isShinyCharmActive: Bool, isLureInUse: Bool) -> Double
	{
		if isShinyCharmActive && isLureInUse
		{
			return Double(catchCombo) / Double(1024) * 100
		}
		else if isShinyCharmActive
		{
			return Double(catchCombo) / Double(1365) * 100
		}
		else if isLureInUse
		{
			return Double(catchCombo) / Double(2048) * 100
		}
		return Double(catchCombo) / Double(4096) * 100
	}

	fileprivate func getLGPETier3Probability(catchCombo: Int, isShinyCharmActive: Bool, isLureInUse: Bool) -> Double
	{
		if isShinyCharmActive && isLureInUse
		{
			return Double(catchCombo) / Double(585) * 100
		}
		else if isShinyCharmActive
		{
			return Double(catchCombo) / Double(683) * 100
		}
		else if isLureInUse
		{
			return Double(catchCombo) / Double(819) * 100
		}

		return Double(catchCombo) / Double(1024) * 100
	}

	fileprivate func getLGPETier2Probability(catchCombo: Int, isShinyCharmActive: Bool, isLureInUse: Bool) -> Double
	{
		if isShinyCharmActive && isLureInUse
		{
			return Double(catchCombo) / Double(372) * 100
		}
		else if isShinyCharmActive
		{
			return Double(catchCombo) / Double(410) * 100
		}
		else if isLureInUse
		{
			return Double(catchCombo) / Double(455) * 100
		}

		return Double(catchCombo) / Double(512) * 100
	}

	fileprivate func getLGPETier1Probability(catchCombo: Int, isShinyCharmActive: Bool, isLureInUse: Bool) -> Double
	{
		if isShinyCharmActive && isLureInUse
		{
			return Double(catchCombo) / Double(273) * 100
		}
		else if isShinyCharmActive
		{
			return Double(catchCombo) / Double(293) * 100
		}
		else if isLureInUse
		{
			return Double(catchCombo) / Double(315) * 100
		}

		return Double(catchCombo) / Double(341) * 100
	}

	func resolveProbability(generation: Int, probability: Double, probabilityLabel: UILabel, encounters: Int)
	{
		var huntIsOverOdds: Bool?

		if generation == 4
		{
			huntIsOverOdds = probability > 100.0
			probabilityLabel.font = settingsRepository.getExtraSmallFont()
		}
		else
		{
			huntIsOverOdds = encounters > settingsRepository.shinyOdds!
			probabilityLabel.font = settingsRepository.getSmallFont()
		}

		if huntIsOverOdds!
		{
			probabilityLabel.text = " Your hunt has gone over odds."
		}
		else
		{
			let formattedProbability = String(format: "%.2f", probability)

			probabilityLabel.text = " Probability is \(formattedProbability)%"
		}
	}

	func getLGPEOdds(catchCombo: Int, isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
	{
		if catchCombo >= 0 && catchCombo <= 10
		{
			return getLGPETier4Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		else if catchCombo >= 11 && catchCombo <= 20
		{
			return getLGPETier3Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		else if catchCombo >= 21 && catchCombo <= 30
		{
			return getLGPETier2Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}

		return getLGPETier1Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
	}

	fileprivate func getLGPETier4Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
	{
		if isShinyCharmActive && isLureInUse
		{
			return 1024
		}
		else if isShinyCharmActive
		{
			return 1365
		}
		else if isLureInUse
		{
			return 2048
		}

		return 4096
	}

	fileprivate func getLGPETier3Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
	{
		if isShinyCharmActive && isLureInUse
		{
			return 585
		}
		else if isShinyCharmActive
		{
			return 683
		}
		else if isLureInUse
		{
			return 819
		}

		return 1024
	}

	fileprivate func getLGPETier2Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
	{
		if isShinyCharmActive && isLureInUse
		{
			return 372
		}
		else if isShinyCharmActive
		{
			return 410
		}
		else if isLureInUse
		{
			return 455
		}

		return 512
	}

	fileprivate func getLGPETier1Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
	{
		if isShinyCharmActive && isLureInUse
		{
			return 273
		}
		else if isShinyCharmActive
		{
			return 293
		}
		else if isLureInUse
		{
			return 315
		}

		return 341
	}
}
