//
//  ProbabilityService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class ProbabilityService
{
	fileprivate let lgpeProbabilityService = LGPEProbabilityService()
	fileprivate let gen8ProbabilityService = Gen8ProbabilityService()
	fileprivate let settingsRepository = SettingsRepository.settingsRepositorySingleton

	func getProbability(generation: Int, isCharmActive: Bool, encounters: Int, shinyOdds: Int, isLureInUse: Bool) -> Double
	{
		if generation == 3
		{
			return gen8ProbabilityService.getProbability(battles: encounters, isCharmActive: isCharmActive)
		}
		else if generation == 4
		{
			return lgpeProbabilityService.getProbability(combo: encounters, isCharmActive: isCharmActive, isLureInUse: isLureInUse)
		}
		return Double.getProbability(encounters: encounters, odds: shinyOdds)
	}

	func getProbabilityText(encounters: Int, shinyOdds: Int, probability: Double) -> String
	{
		let huntIsOverOdds = encounters > shinyOdds

		if huntIsOverOdds
		{
			return " Hunt has gone over odds."
		}
		else
		{
			let formattedProbability = String(format: "%.2f", probability)
			return " Probability is \(formattedProbability)%"
		}
	}
}
