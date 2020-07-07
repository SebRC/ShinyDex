//
//  DexNavOddsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 06/07/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class DexNavOddsService
{
	func getOdds(searchLevel: Int, isShinyCharmActive: Bool) -> Int
	{
		let withBonus = calculateDexNavProbability(randomBonus: true, searchLevel: searchLevel, isShinyCharmActive: isShinyCharmActive)
		let withoutBonus = calculateDexNavProbability(randomBonus: false, searchLevel: searchLevel, isShinyCharmActive: isShinyCharmActive)

		let totalProbability = 0.04 * withBonus + 0.96 * withoutBonus
		let odds = Int(round(1.0/totalProbability))
		return odds
	}

	fileprivate func calculateDexNavProbability(randomBonus: Bool, searchLevel: Int, isShinyCharmActive: Bool) -> Double
	{
		var counter = Double(searchLevel)
		var d0 = 0.0
		if counter > 200
		{
			d0 += counter - 200.0
			counter = 200
		}

		if counter > 100
		{
			d0 += counter * 2 - 200.0
			counter = 100
		}

		if counter > 0
		{
			d0 += counter * 6.0
		}

		let d8 = ceil(d0 * 0.01)

		var recompute = 1 + (isShinyCharmActive ? 2 : 0) + (randomBonus ? 4 : 0) as Double
		let dexNavProbability = 1.0 - pow((1.0 - (d8 / 10000)), recompute)

		recompute = isShinyCharmActive ? 3 : 1

		let shinyPIDProbability = 1.0 - pow(1.0 - (1.0 / 4096), recompute) as Double
		let totalProbability = ((1.0 - dexNavProbability) * shinyPIDProbability) + (dexNavProbability * 1)

		return totalProbability
	}
}
