//
//  LGPEProbabilityService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 27/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class LGPEProbabilityService
{
	fileprivate var isShinyCharmActive = false
	fileprivate var isLureActive = false
	fileprivate var catchCombo = 0

	func getProbability(combo: Int, isCharmActive: Bool, huntMethod: HuntMethod) -> Double
	{
		isShinyCharmActive = isCharmActive
		isLureActive = huntMethod == HuntMethod.Lure
		catchCombo = combo

		if combo >= 0 && combo <= 10
		{
			return getTier4Probability()
		}
		else if combo >= 11 && combo <= 20
		{
			return getTier3Probability()
		}
		else if combo >= 21 && combo <= 30
		{
			return getTier2Probability()
		}
		return getTier1Probability()
	}

	fileprivate func getTier4Probability() -> Double
	{
		if isShinyCharmActive && isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 1024)
		}
		else if isShinyCharmActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 1365)
		}
		else if isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 2048)
		}
		return Double.getProbability(encounters: catchCombo, odds: 4096)
	}

	fileprivate func getTier3Probability() -> Double
	{
		if isShinyCharmActive && isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 585)
		}
		else if isShinyCharmActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 683)
		}
		else if isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 819)
		}
		return Double.getProbability(encounters: catchCombo, odds: 1024)
	}

	fileprivate func getTier2Probability() -> Double
	{
		if isShinyCharmActive && isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 372)
		}
		else if isShinyCharmActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 410)
		}
		else if isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 455)
		}
		return Double.getProbability(encounters: catchCombo, odds: 512)
	}

	fileprivate func getTier1Probability() -> Double
	{
		if isShinyCharmActive && isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 273)
		}
		else if isShinyCharmActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 293)
		}
		else if isLureActive
		{
			return Double.getProbability(encounters: catchCombo, odds: 315)
		}
		return Double.getProbability(encounters: catchCombo, odds: 341)
	}
}
