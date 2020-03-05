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
	var currentHuntPokemon = [Pokemon]()
	var currentHuntNames = [String]()
	fileprivate var pokemonList = PokemonRepository.pokemonRepositorySingleton.pokemonList

	fileprivate var currentHuntRepository: CurrentHuntRepository?

	init()
	{
		currentHuntRepository = CurrentHuntRepository()
		currentHuntNames = currentHuntRepository!.getCurrenHuntNames()
		constructCurrentHunt()
	}
	
	fileprivate func constructCurrentHunt()
	{
		for name in currentHuntNames
		{
			for pokemon in pokemonList
			{
				if name == pokemon.name
				{
					currentHuntPokemon.append(pokemon)
					break
				}
			}
		}
		sortCurrentHunt()
	}

	fileprivate func sortCurrentHunt()
	{
		currentHuntPokemon = currentHuntPokemon.sorted(by: { $0.number < $1.number})
	}

	func addToCurrentHunt(pokemon: Pokemon)
	{
		currentHuntPokemon.append(pokemon)
		currentHuntNames.append(pokemon.name)

		save()

		sortCurrentHunt()
	}

	func save()
	{
		currentHuntRepository!.save(names: currentHuntNames)
	}

	func clearCurrentHunt()
	{
		currentHuntPokemon.removeAll()

		currentHuntNames.removeAll()

		currentHuntRepository!.save(names: currentHuntNames)
	}
}
