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
		switch gen
		{
		case 1:
			return "Johto"
		case 2:
			return "Hoenn"
		case 3:
			return "Sinnoh"
		case 4:
			return "Unova"
		case 5:
			return "Kalos"
		case 6:
			return "Alola"
		case 7:
			return "Galar"
		case 8:
			return "Hunts"
		case 9:
			return "Collection"
		default:
			return "Kanto"
		}
	}

	func getEncountersLabelText(pokemon: Pokemon, encounters: Int, methodDecrement: Int = 0) -> String
	{
		let encountersDecremented = encounters - methodDecrement
		var maxChainReached = false
		var methodVerb = "Chain"

		if pokemon.huntMethod == .Lure || pokemon.huntMethod == .SosChaining
		{
			maxChainReached = encounters > 30
		}
		else if pokemon.huntMethod == .ChainFishing
		{
			maxChainReached = encounters > 20
		}
		else if pokemon.huntMethod == .Pokeradar
		{
			maxChainReached = encounters > 40
		}
		else if pokemon.huntMethod == .DexNav
		{
			maxChainReached = encounters > 999
		}

		if pokemon.generation == 0
		{
			return maxChainReached
				? " Catch Combo: \(methodDecrement) + \(encountersDecremented) seen"
				: " Catch Combo: \(encounters)"
		}
		else if pokemon.huntMethod == .Masuda || pokemon.huntMethod == .Gen2Breeding
		{
			return " Eggs: \(encounters)"
		}
		else if pokemon.huntMethod == .SosChaining || pokemon.huntMethod == .ChainFishing || pokemon.huntMethod == .Pokeradar
		{
			return maxChainReached
				? " \(methodVerb): \(methodDecrement) + \(encountersDecremented) \(pokemon.huntMethod == .Pokeradar ? "patches" : "seen")"
				: " \(methodVerb): \(encounters)"
		}
		else if pokemon.huntMethod == .DexNav
		{
			methodVerb = "Search level"
			return maxChainReached
			? " \(methodVerb): \(methodDecrement) + \(encountersDecremented) seen"
			: " \(methodVerb): \(encounters)"
		}
		else
		{
			return " Encounters: \(encounters)"
		}
	}
}
