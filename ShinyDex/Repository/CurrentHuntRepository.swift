//
//  CurrentHuntRepository.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/10/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation

class CurrentHuntRepository
{
	var currentlyHunting = [Pokemon]()
	var currentHuntNames = [String]()
	let defaults = UserDefaults.standard
	var pokemonList = PokemonRepository.pokemonRepositorySingleton.pokemonList
	
	static let currentHuntRepositorySingleton = CurrentHuntRepository()

	func saveCurrentHunt()
	{
		defaults.set(currentHuntNames, forKey: "currentHunt")
	}
	
	func loadCurrentHunt()
	{
		if let loadedHunt = defaults.array(forKey: "currentHunt") as? [String]
		{
			currentHuntNames = loadedHunt
		}
		
		constructCurrentHuntList()
	}
	
	fileprivate func constructCurrentHuntList()
	{
		for name in currentHuntNames
		{
			for pokemon in pokemonList
			{
				if name == pokemon.name
				{
					currentlyHunting.append(pokemon)
				}
			}
		}
		
		sortCurrentHunt()
	}
	
	func addToCurrentHunt(pokemon: Pokemon)
	{
		currentlyHunting.append(pokemon)
		currentHuntNames.append(pokemon.name)
		
		saveCurrentHunt()
		
		sortCurrentHunt()
	}
	
	fileprivate func sortCurrentHunt()
	{
		currentlyHunting = currentlyHunting.sorted(by: { $0.number < $1.number})
	}
	
	func clearCurrentHunt()
	{
		currentlyHunting.removeAll()
		
		currentHuntNames.removeAll()
		
		saveCurrentHunt()
	}
}
