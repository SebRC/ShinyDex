//
//  SosOddsService.swift
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
		if isShinyCharmActive
		{
			if chain >= 0 && chain <= 10
			{
				return 1366
			}
			else if chain >= 11 && chain <= 20
			{
				return 585
			}
			else if chain >= 21 && chain <= 30
			{
				return 373
			}
			return 273
		}
		else
		{
			if chain >= 0 && chain <= 10
			{
				return 4096
			}
			else if chain >= 11 && chain <= 20
			{
				return 820
			}
			else if chain >= 21 && chain <= 30
			{
				return 455
			}
			return 315
		}
	}
}
