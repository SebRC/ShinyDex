//
//  PokemonRepository.swift
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
	fileprivate var pokemonEntityList: [NSManagedObject] = []
	var pokemonList: [Pokemon] = []
	var generation = 1
	var dispatchGroup : DispatchGroup
	let txtReader = TxtReader()
	var appDelegate: AppDelegate
	var managedContext: NSManagedObjectContext
	var entity: NSEntityDescription
	
	static let pokemonRepositorySingleton = PokemonRepository()
	
	fileprivate init()
	{
		appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
		
		managedContext = appDelegate.persistentContainer.viewContext
		
		entity = NSEntityDescription.entity(forEntityName: "PokemonEntity", in: managedContext)!
		
		dispatchGroup = DispatchGroup()
	}
	
	func populatePokemonList()
	{
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PokemonEntity")

		do
		{
		  pokemonEntityList = try managedContext.fetch(fetchRequest)
			
		  for pokemonEntity in pokemonEntityList
		  {
			  pokemonList.append(Pokemon(pokemonEntity: pokemonEntity))
		  }
			
		}
		catch let error as NSError
		{
		  print("Could not fetch. \(error), \(error.userInfo)")
		}
	}
	
	func populateDatabase()
	{
		let genText = "allGens"
		let list = txtReader.linesFromResourceForced(textFile: genText)

		var count = 0
		
		for pokemonName in list
		{
			dispatchGroup.enter()
			let pokemonEntity = NSManagedObject(entity: entity, insertInto: managedContext)
			
			pokemonEntity.setValue(pokemonName, forKey: "name")
			pokemonEntity.setValue(count, forKey: "number")
			pokemonEntity.setValue(0, forKey: "encounters")
			pokemonEntity.setValue("Not Caught", forKey: "caughtDescription")
			pokemonEntity.setValue("none", forKey: "caughtBall")
			
			let pokemon = Pokemon(pokemonEntity: pokemonEntity)
			
			savePokemon(pokemon: pokemon)
			
			pokemonList.append(pokemon)
			
			dispatchGroup.leave()
			count += 1
		}
	}
	
	func savePokemon(pokemon: Pokemon)
	{
		pokemon.pokemonEntity.setValue(pokemon.name, forKey: "name")
		pokemon.pokemonEntity.setValue(pokemon.encounters, forKey: "encounters")
		pokemon.pokemonEntity.setValue(pokemon.caughtDescription, forKey: "caughtDescription")
		pokemon.pokemonEntity.setValue(pokemon.caughtBall, forKey: "caughtBall")
		
		do
		{
			try managedContext.save()
		}
		catch let error as NSError
		{
			print("Could not save \(pokemon.name). \(error.localizedDescription)")
		}
	}
	
	func deleteAll()
	{
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonEntity")

		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

		do
		{
			try managedContext.execute(batchDeleteRequest)
		}
		catch
		{
		}
	}
}
