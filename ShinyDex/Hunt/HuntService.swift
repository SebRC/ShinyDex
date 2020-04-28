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
		return hunts
	}

	func save(hunt: Hunt)
	{
		huntRepository.save(hunt: hunt)
	}

	func clear()
	{
		huntRepository.clear()
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
		huntRepository.delete(hunt: hunt)
	}

	func createNewHuntWithPokemon(hunts: inout [Hunt], pokemon: Pokemon, popupView: PopupView, popupHandler: PopupHandler)
	{
		let hunt = Hunt(name: "New Hunt", pokemon: [Pokemon]())
		hunt.pokemon.append(pokemon)
		hunt.names.append(pokemon.name)
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		hunts.append(hunt)
		huntRepository.save(hunt: hunt)
		popupView.actionLabel.text = "\(pokemon.name) was added to \(hunt.name)."
		popupHandler.showPopup(popupView: popupView)
	}

	func addToOnlyExistingHunt(hunts: inout [Hunt], pokemon: Pokemon, popupView: PopupView, popupHandler: PopupHandler)
	{
		hunts[0].pokemon.append(pokemon)
		hunts[0].names.append(pokemon.name)
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		huntRepository.save(hunt: hunts[0])
		popupView.actionLabel.text = "\(pokemon.name) was added to \(hunts[0].name)."
		popupHandler.showPopup(popupView: popupView)
	}
}
