//
//  TextResolver.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/10/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation

class TextResolver
{
	func getGenTitle(gen: Int) -> String
	{
		if gen == 1
		{
			return "Johto"
		}
		else if gen == 2
		{
			return "Hoenn"
		}
		else if gen == 3
		{
			return "Sinnoh"
		}
		else if gen == 4
		{
			return "Unova"
		}
		else if gen == 5
		{
			return "Kalos"
		}
		else if gen == 6
		{
			return "Alola"
		}
		else if gen == 7
		{
			return "Galar"
		}
		else if gen == 8
		{
			return "Hunts"
		}
		return "Kanto"
	}

	func getEncountersLabelText(huntState: HuntState, encounters: Int, methodDecrement: Int = 0) -> String
	{
		let encountersDecremented = encounters - methodDecrement
		var maxChainReached = false

		if huntState.huntMethod == .Lure || huntState.huntMethod == .SosChaining || huntState.generation == 6
		{
			maxChainReached = encounters > 30
		}
		else if huntState.huntMethod == .ChainFishing
		{
			maxChainReached = encounters > 20
		}
		else if huntState.huntMethod == .Pokeradar
		{
			maxChainReached = encounters > 40
		}

		if huntState.generation == 6
		{
			return maxChainReached
				? " Catch Combo: \(methodDecrement) + \(encountersDecremented) seen"
				: " Catch Combo: \(encounters)"
		}
		else if huntState.huntMethod == .Masuda || huntState.huntMethod == .Gen2Breeding
		{
			return " Eggs: \(encounters)"
		}
		else if huntState.huntMethod == .SosChaining || huntState.huntMethod == .ChainFishing || huntState.huntMethod == .Pokeradar
		{
			return maxChainReached
				? " Chain: \(methodDecrement) + \(encountersDecremented) seen"
				: " Chain: \(encounters)"
		}
		else
		{
			return " Encounters: \(encounters)"
		}
	}
}
