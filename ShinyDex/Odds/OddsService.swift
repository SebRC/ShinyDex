//
//  OddsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 27/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class OddsService
{
	fileprivate let lgpeOddsService = LGPEOddsService()
	fileprivate let gen8OddsService = Gen8OddsService()

	func getShinyOdds(currentGen: Int, isCharmActive: Bool, isLureInUse: Bool, encounters: Int) -> Int
	{
		if currentGen == 0
		{
			return 8192
		}
		else if currentGen == 1 && !isCharmActive
		{
			return 8192
		}
		else if currentGen == 1
		{
			return 2731
		}
		else if currentGen > 1 && currentGen < 3 && !isCharmActive
		{
			return 4096
		}
		else if currentGen == 3
		{
			let gen8Odds = gen8OddsService.getOdds(battles: encounters, isCharmActive: isCharmActive)
			return gen8Odds
		}
		else if currentGen == 4
		{
			let letsGoOdds = lgpeOddsService.getOdds(catchCombo: encounters, isCharmActive: isCharmActive, isLureInUse: isLureInUse)

			return letsGoOdds
		}
		else
		{
			return 1365
		}
	}
}
