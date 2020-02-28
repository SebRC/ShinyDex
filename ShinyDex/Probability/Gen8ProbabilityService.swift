//
//  Gen8ProbabilityService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class Gen8ProbabilityService
{
	fileprivate var isShinyCharmActive = false
	fileprivate var numberOfbattles = 0

	func getProbability(battles: Int, isCharmActive: Bool) -> Double
	{
		isShinyCharmActive = isCharmActive
		numberOfbattles = battles

		if battles < 50
		{
			return getTier6Probability()
		}
		else if battles > 50 && battles < 100
		{
			return getTier5Probability()
		}
		else if battles > 100 && battles < 200
		{
			return getTier4Probability()
		}
		else if battles > 200 && battles < 300
		{
			return getTier3Probability()
		}
		else if battles > 300 && battles < 500
		{
			return getTier2Probability()
		}
		return getTier1Probability()
	}

	fileprivate func getTier6Probability() -> Double
	{
		if isShinyCharmActive
		{
			return Double.getProbability(encounters: numberOfbattles, odds: 1365)
		}
		return Double.getProbability(encounters: numberOfbattles, odds: 4096)
	}

	fileprivate func getTier5Probability() -> Double
	{
		if isShinyCharmActive
		{
			return Double.getProbability(encounters: numberOfbattles, odds: 1024)
		}
		return Double.getProbability(encounters: numberOfbattles, odds: 2048)
	}

	fileprivate func getTier4Probability() -> Double
	{
		if isShinyCharmActive
		{
			return Double.getProbability(encounters: numberOfbattles, odds: 819)
		}
		return Double.getProbability(encounters: numberOfbattles, odds: 1365)
	}

	fileprivate func getTier3Probability() -> Double
	{
		if isShinyCharmActive
		{
			return Double.getProbability(encounters: numberOfbattles, odds: 683)
		}
		return Double.getProbability(encounters: numberOfbattles, odds: 1024)
	}

	fileprivate func getTier2Probability() -> Double
	{
		if isShinyCharmActive
		{
			return Double.getProbability(encounters: numberOfbattles, odds: 585)
		}
		return Double.getProbability(encounters: numberOfbattles, odds: 819)
	}

	fileprivate func getTier1Probability() -> Double
	{
		if isShinyCharmActive
		{
			return Double.getProbability(encounters: numberOfbattles, odds: 512)
		}
		return Double.getProbability(encounters: numberOfbattles, odds: 683)
	}
}
