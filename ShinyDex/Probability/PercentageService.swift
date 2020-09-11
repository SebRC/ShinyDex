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

	func getPercentageText(encounters: Int, shinyOdds: Int, percentage: Double, huntState: HuntState, methodDecrement: Int) -> String
	{
		let huntIsOverOdds = encounters - methodDecrement > shinyOdds
		let methodVerb = huntState.generation == 5 ? "Battle" : "Chain"

		if huntState.huntMethod == .Lure && encounters <= 30
			|| huntState.generation == 6 && encounters <= 30
			|| huntState.huntMethod == .Pokeradar && encounters <= 40
			|| huntState.huntMethod == .ChainFishing && encounters <= 20
			|| huntState.huntMethod == .SosChaining && encounters <= 30
			|| huntState.generation == 5 && huntState.huntMethod != .Masuda && encounters <= 500
		{
			return " \(methodVerb) \(methodDecrement) to see percentage"
		}

		if huntState.huntMethod == .DexNav && encounters <= 999
		{
			return " Reach search level \(methodDecrement) to see percentage"
		}

		if huntIsOverOdds
		{
			return " Hunt has gone over odds"
		}
		else
		{
			let formattedPercentage = String(format: "%.2f", percentage)
			return " Percentage of odds is \(formattedPercentage)%"
		}
	}
}
