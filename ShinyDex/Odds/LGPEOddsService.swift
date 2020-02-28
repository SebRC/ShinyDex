//
//  LGPEOdssService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 27/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class LGPEOddsService
{
	func getOdds(catchCombo: Int, isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
	{
		if catchCombo >= 0 && catchCombo <= 10
		{
			return getTier4Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		else if catchCombo >= 11 && catchCombo <= 20
		{
			return getTier3Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		else if catchCombo >= 21 && catchCombo <= 30
		{
			return getTier2Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		return getTier1Odds(isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
	}

	fileprivate func getTier4Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
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

	fileprivate func getTier3Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
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

	fileprivate func getTier2Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
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

	fileprivate func getTier1Odds(isShinyCharmActive: Bool, isLureInUse: Bool) -> Int
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
