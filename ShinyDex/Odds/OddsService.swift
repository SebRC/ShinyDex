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
	fileprivate let masudaOddsService = MasudaOddsService()
	fileprivate let gen2BreedingOddsService = Gen2BreedingOddsService()

	func getShinyOdds(generation: Int, isCharmActive: Bool, huntMethod: HuntMethod, encounters: Int = 0) -> Int
	{
		if huntMethod == .Masuda
		{
			return masudaOddsService.getOdds(generation: generation, isCharmActive: isCharmActive)
		}
		if huntMethod == .Gen2Breeding
		{
			return gen2BreedingOddsService.getOdds()
		}
		if generation == 0 || generation == 1 || generation == 2 && !isCharmActive
		{
			return 8192
		}
		else if generation == 2
		{
			return 2731
		}
		else if generation > 2 && generation < 5 && !isCharmActive
		{
			return 4096
		}
		else if generation > 2 && generation < 5
		{
			return 1365
		}
		else if generation == 5
		{
			return gen8OddsService.getOdds(battles: encounters, isCharmActive: isCharmActive)
		}
		return lgpeOddsService.getOdds(catchCombo: encounters, isCharmActive: isCharmActive, huntMethod: huntMethod)
	}
}
