//
//  CurrentHuntService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 05/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class CurrentHuntService
{
	fileprivate var pokemonService = PokemonService()
	fileprivate var currentHuntRepository = CurrentHuntRepository()
	
	func get() -> [Pokemon]
	{
		let allPokemon = pokemonService.getAll()
		let currentHuntNames = currentHuntRepository.getCurrenHuntNames()
		var currentHuntPokemon = [Pokemon]()
		for name in currentHuntNames
		{
			for pokemon in allPokemon
			{
				if name == pokemon.name
				{
					currentHuntPokemon.append(pokemon)
					break
				}
			}
		}
		currentHuntPokemon = currentHuntPokemon.sorted(by: { $0.number < $1.number})
		return currentHuntPokemon
	}

	func getCurrentHuntNames() -> [String]
	{
		return currentHuntRepository.getCurrenHuntNames()
	}

	func save(currentHuntNames: [String])
	{
		currentHuntRepository.save(names: currentHuntNames)
	}

	func clearCurrentHunt()
	{
		currentHuntRepository.save(names: [String]())
	}
}
