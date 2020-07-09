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
	fileprivate let friendSafariOddsService = FriendSafariOddsService()
	fileprivate let chainFishingOddsService = ChainFishingOddsService()
	fileprivate let sosChainingOddsService = SosChainingOddsService()
	fileprivate let pokeradarOddsService = PokeradarOddsService()
	fileprivate let dexNavOddsService = DexNavOddsService()

	func getShinyOdds(generation: Int, isCharmActive: Bool, huntMethod: HuntMethod, encounters: Int = 0) -> Int
	{
		switch huntMethod {
		case .Gen2Breeding:
			return gen2BreedingOddsService.getOdds()
		case .Masuda:
			return masudaOddsService.getOdds(generation: generation, isCharmActive: isCharmActive)
		case .Pokeradar:
			return pokeradarOddsService.getOdds(chain: encounters)
		case .FriendSafari:
			return friendSafariOddsService.getOdds(isShinyCharmActive: isCharmActive)
		case .ChainFishing:
			return chainFishingOddsService.getOdds(isShinyCharmActive: isCharmActive, chain: encounters)
		case .DexNav:
			return dexNavOddsService.getOdds(searchLevel: encounters, isShinyCharmActive: isCharmActive)
		case .SosChaining:
			return sosChainingOddsService.getOdds(isShinyCharmActive: isCharmActive, chain: encounters)
		default:
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
}
