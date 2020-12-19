//
//  SosChainingOddsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 03/07/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class SosChainingOddsService
{
	func getOdds(isShinyCharmActive: Bool, chain: Int) -> Int
	{
		if chain >= 0 && chain <= 10
		{
			return isShinyCharmActive ? 1366 : 4096
		}
		else if chain >= 11 && chain <= 20
		{
			return isShinyCharmActive ? 585 : 820
		}
		else if chain >= 21 && chain <= 30
		{
			return isShinyCharmActive ? 373 : 455
		}
		return isShinyCharmActive ? 273 : 315
	}
}
