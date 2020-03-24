//
//  HuntStateService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 24/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class HuntStateService
{
	var generation: Int
	var isShinyCharmActive: Bool
	var isLureInUse: Bool
	var shinyOdds: Int?

	var oddsService = OddsService()
	fileprivate var huntStateRepository = HuntStateRepository()

	init()
	{
		generation = huntStateRepository.generation
		isShinyCharmActive = huntStateRepository.isShinyCharmActive
		isLureInUse = huntStateRepository.isLureInUse
		setShinyOdds()
	}

	func setShinyOdds()
	{
		shinyOdds = oddsService.getShinyOdds(currentGen: generation, isCharmActive: isShinyCharmActive, isLureInUse: isLureInUse, encounters: 0)
	}

	func changeIsShinyCharmActive(isSwitchOn: Bool)
	{
		isShinyCharmActive = isSwitchOn
		save()
	}

	func changeIsLureInUseActive(isSwitchOn: Bool)
	{
		isLureInUse = isSwitchOn
		save()
	}

	func save()
	{
		huntStateRepository.save(generation: generation, isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
	}
}
