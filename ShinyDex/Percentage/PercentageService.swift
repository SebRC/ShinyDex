//
//  PercentageService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class PercentageService
{
	func getPercentage(encounters: Int, shinyOdds: Int) -> Double
	{
		return Double.getPercentage(encounters: encounters, odds: shinyOdds)
	}

	func getPercentageText(encounters: Int, shinyOdds: Int, percentage: Double, pokemon: Pokemon, methodDecrement: Int) -> String
	{
		let huntIsOverOdds = encounters - methodDecrement > shinyOdds

		if pokemon.huntMethod == .Lure && encounters <= 30
			|| pokemon.generation == 0 && encounters <= 30
			|| pokemon.huntMethod == .Pokeradar && encounters <= 40
			|| pokemon.huntMethod == .ChainFishing && encounters <= 20
			|| pokemon.huntMethod == .SosChaining && encounters <= 30
		{
			return " Chain \(methodDecrement) to see percentage"
		}

		if pokemon.huntMethod == .DexNav && encounters <= 999
		{
			return " Reach Search level \(methodDecrement) to see percentage"
		}

		if huntIsOverOdds
		{
			let formattedPercentage = String(format: "%.2f", percentage - 100)
			return " Hunt is \(formattedPercentage)% over odds"
		}
		else
		{
			let formattedPercentage = String(format: "%.2f", percentage)
			return " Percentage of odds is \(formattedPercentage)%"
		}
	}
}
