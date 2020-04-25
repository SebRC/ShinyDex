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
		let currentHuntEntities = currentHuntRepository.getAll()
		var currentHunts = [Hunt]()
		for huntEntity in currentHuntEntities
		{
			currentHunts.append(Hunt(huntEntity: huntEntity))
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
}
