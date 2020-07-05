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
	func getProbability(encounters: Int, shinyOdds: Int) -> Double
	{
		return Double.getProbability(encounters: encounters, odds: shinyOdds)
	}

	func getProbabilityText(encounters: Int, shinyOdds: Int, probability: Double, huntState: HuntState, methodDecrement: Int) -> String
	{
		let huntIsOverOdds = encounters - methodDecrement > shinyOdds
		let methodVerb = huntState.generation == 5 ? "Battle" : "Chain"

		if huntState.huntMethod == .Lure && encounters <= 30
			|| huntState.generation == 6 && encounters <= 30
			|| huntState.huntMethod == .Pokeradar && encounters <= 40
			|| huntState.huntMethod == .ChainFishing && encounters <= 20
			|| huntState.huntMethod == .SosChaining && encounters <= 30
			|| huntState.generation == 5 && encounters <= 500
		{
			return " \(methodVerb) \(methodDecrement) to see probability"
		}

		if huntIsOverOdds
		{
			return " Hunt has gone over odds"
		}
		else
		{
			let formattedProbability = String(format: "%.2f", probability)
			return " Probability is \(formattedProbability)%"
		}
	}
}
