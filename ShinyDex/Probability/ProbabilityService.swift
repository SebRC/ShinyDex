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

	func getProbabilityText(encounters: Int, shinyOdds: Int, probability: Double, pokemon: Pokemon, methodDecrement: Int) -> String
	{
		if pokemon.huntMethod == .Lure && encounters <= 30
			|| pokemon.generation == 0 && encounters <= 30
			|| pokemon.huntMethod == .Pokeradar && encounters <= 40
			|| pokemon.huntMethod == .ChainFishing && encounters <= 20
			|| pokemon.huntMethod == .SosChaining && encounters <= 30
		{
			return " Chain \(methodDecrement) to see probability"
		}

		if pokemon.huntMethod == .DexNav && encounters <= 999
		{
			return " Reach Search level \(methodDecrement) to see probability"
		}

		let formattedProbability = String(format: "%.2f", probability)
		return " Probability is \(formattedProbability)%"
	}
}
