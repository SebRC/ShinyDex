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
	var oddsService = OddsService()
	fileprivate var huntStateRepository = HuntStateRepository()

	func get() -> HuntState
	{
		let huntState = huntStateRepository.get()
		huntState.shinyOdds = oddsService.getShinyOdds(huntState.generation, huntState.isShinyCharmActive, huntState.isLureInUse, 0)
		return huntState
	}

	func save(_ huntState: HuntState)
	{
		huntStateRepository.save(huntState)
	}
}
