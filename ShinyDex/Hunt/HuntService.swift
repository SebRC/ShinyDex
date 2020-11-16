//
//  HuntService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 05/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import CoreData

class HuntService
{
	fileprivate var pokemonService = PokemonService()
	fileprivate var huntRepository = HuntRepository()
	
	func getAll() -> [Hunt]
	{
		let pokemon = pokemonService.getAll()
		let currentHuntEntities = huntRepository.getAll()
		var hunts = [Hunt]()
		for huntEntity in currentHuntEntities
		{
			hunts.append(constructHunt(huntEntity: huntEntity, allPokemon: pokemon))
		}
		for hunt in hunts
		{
			hunt.pokemon = hunt.pokemon.sorted(by: { $0.number < $1.number})
		}
		return hunts.sorted(by: { $0.priority < $1.priority})
	}

	func save(hunt: Hunt)
	{
		huntRepository.save(hunt: hunt)
	}

	func clear()
	{
		huntRepository.clear()
	}

	func delete(hunt: Hunt)
	{
		huntRepository.delete(hunt: hunt)
	}

	func createNewHuntWithPokemon(hunts: inout [Hunt], pokemon: Pokemon)
	{
		let hunt = Hunt(name: "New Hunt", pokemon: [Pokemon](), priority: 0)
		hunt.pokemon.append(pokemon)
		hunt.indexes.append(pokemon.number)
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		hunt.totalEncounters = pokemon.encounters
		hunts.append(hunt)
		huntRepository.save(hunt: hunt)
	}

	func addToOnlyExistingHunt(hunts: inout [Hunt], pokemon: Pokemon)
	{
		hunts[0].pokemon.append(pokemon)
		hunts[0].indexes.append(pokemon.number)
		hunts[0].totalEncounters += pokemon.encounters
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		huntRepository.save(hunt: hunts[0])
	}

	fileprivate func constructHunt(huntEntity: NSManagedObject, allPokemon: [Pokemon]) -> Hunt
	{
		let hunt = Hunt(huntEntity: huntEntity)
		for index in hunt.indexes
		{
			let pokemon = allPokemon[index]
			hunt.pokemon.append(pokemon)
			hunt.totalEncounters += pokemon.encounters
		}
		return hunt
	}
}
