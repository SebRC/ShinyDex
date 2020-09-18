//
//  PokemonService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class PokemonRepository
{
	fileprivate var appDelegate: AppDelegate
	fileprivate var managedContext: NSManagedObjectContext
	fileprivate var entity: NSEntityDescription
	
	init()
	{
		appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
		
		managedContext = appDelegate.persistentContainer.viewContext
		
		entity = NSEntityDescription.entity(forEntityName: "PokemonEntity", in: managedContext)!
	}
	
	func getAll() -> [NSManagedObject]
	{
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PokemonEntity")
		var pokemonEntityList = [NSManagedObject]()
		do
		{
			pokemonEntityList = try managedContext.fetch(fetchRequest)
			return pokemonEntityList
		}
		catch let error as NSError
		{
			print("Could not fetch PokemonEntity table. \(error.localizedDescription)")
		}
		return []
	}
	
	func save(pokemon: Pokemon)
	{
		pokemon.pokemonEntity.setValue(pokemon.name, forKey: "name")
		pokemon.pokemonEntity.setValue(pokemon.encounters, forKey: "encounters")
		pokemon.pokemonEntity.setValue(pokemon.caughtDescription, forKey: "caughtDescription")
		pokemon.pokemonEntity.setValue(pokemon.caughtBall, forKey: "caughtBall")
		pokemon.pokemonEntity.setValue(pokemon.isBeingHunted, forKey: "isBeingHunted")

		pokemon.pokemonEntity.setValue(pokemon.generation, forKey: "generation")
		pokemon.pokemonEntity.setValue(pokemon.isShinyCharmActive, forKey: "isShinyCharmActive")
		pokemon.pokemonEntity.setValue(pokemon.shinyOdds, forKey: "shinyOdds")
		pokemon.pokemonEntity.setValue(pokemon.huntMethod.rawValue, forKey: "huntMethod")
		pokemon.pokemonEntity.setValue(pokemon.increment, forKey: "increment")
		pokemon.pokemonEntity.setValue(pokemon.useIncrementInHunts, forKey: "useIncrementInHunts")
		
		do
		{
			try managedContext.save()
		}
		catch let error as NSError
		{
			print("Could not save \(pokemon.name). \(error.localizedDescription)")
		}
	}

	func save(name: String, number: Int)
	{
		let pokemonEntity = NSManagedObject(entity: entity, insertInto: managedContext)

		pokemonEntity.setValue(name, forKey: "name")
		pokemonEntity.setValue(number, forKey: "number")
		pokemonEntity.setValue(0, forKey: "encounters")
		pokemonEntity.setValue("Not Caught", forKey: "caughtDescription")
		pokemonEntity.setValue("none", forKey: "caughtBall")
		pokemonEntity.setValue(false, forKey: "isBeingHunted")

		pokemonEntity.setValue(0, forKey: "generation")
		pokemonEntity.setValue(false, forKey: "isShinyCharmActive")
		pokemonEntity.setValue(8192, forKey: "shinyOdds")
		pokemonEntity.setValue(HuntMethod.Encounters.rawValue, forKey: "huntMethod")
		pokemonEntity.setValue(1, forKey: "increment")
		pokemonEntity.setValue(false, forKey: "useIncrementInHunts")

		let pokemon = Pokemon(pokemonEntity: pokemonEntity)

		save(pokemon: pokemon)
	}

	func deleteAll()
	{
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PokemonEntity")
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

		do
		{
			try managedContext.execute(deleteRequest)
		}
		catch let error as NSError
		{
			print("An error ocurred when deleting all entities: \(error.localizedDescription)")
		}
	}
}
