//
//  CurrentHuntService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 05/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import CoreData

class CurrentHuntService
{
	fileprivate var pokemonService = PokemonService()
	fileprivate var currentHuntRepository = CurrentHuntRepository()
	
	func getAll() -> [Hunt]
	{
		let pokemon = pokemonService.getAll()
		let currentHuntEntities = currentHuntRepository.getAll()
		var currentHunts = [Hunt]()
		for huntEntity in currentHuntEntities
		{
			currentHunts.append(constructHunt(huntEntity: huntEntity, allPokemon: pokemon))
		}
		for hunt in currentHunts
		{
			hunt.pokemon = hunt.pokemon.sorted(by: { $0.number < $1.number})
		}
		return currentHunts
	}

	func save(hunt: Hunt)
	{
		currentHuntRepository.save(hunt: hunt)
	}

	func clear()
	{
		currentHuntRepository.clear()
	}

	func constructHunt(huntEntity: NSManagedObject, allPokemon: [Pokemon]) -> Hunt
	{
		let names = huntEntity.value(forKey: "names") as! [String]
		let hunt = Hunt(huntEntity: huntEntity)
		for pokemon in allPokemon
		{
			for name in names
			{
				if name == pokemon.name
				{
					hunt.pokemon.append(pokemon)
					break
				}
			}
		}
		return hunt
	}

	func delete(hunt: Hunt)
	{
		currentHuntRepository.delete(hunt: hunt)
	}
}
