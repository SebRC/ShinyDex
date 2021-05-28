//
//  ProbabilityService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class ProbabilityService {
	func getProbability(encounters: Int, shinyOdds: Int) -> Double {
		return Double.getProbability(encounters: encounters, odds: shinyOdds)
	}

	func getProbabilityText(probability: Double, pokemon: Pokemon, methodDecrement: Int) -> String {
		let encounters = pokemon.encounters
		let maxChainNotReached = encounters <= methodDecrement
		if (pokemon.huntMethod == .Lure && maxChainNotReached
			|| pokemon.generation == 0 && maxChainNotReached
			|| pokemon.huntMethod == .Pokeradar && maxChainNotReached
			|| pokemon.huntMethod == .ChainFishing && maxChainNotReached
			|| pokemon.huntMethod == .SosChaining && maxChainNotReached) {
			return " Chain \(methodDecrement) to see probability"
		}

		if (pokemon.huntMethod == .DexNav && maxChainNotReached) {
			return " Reach Search level \(methodDecrement) to see probability"
		}

		let formattedProbability = String(format: "%.2f", probability)
		return " Probability is \(formattedProbability)%"
	}
}
