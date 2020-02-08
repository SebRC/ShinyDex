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
	var pokemonList: [NSManagedObject] = []
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
		
		entity = NSEntityDescription.entity(forEntityName: "Pokemon", in: managedContext)!
		
		dispatchGroup = DispatchGroup()
	}
	
	func getAll() -> [NSManagedObject]
	{
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pokemon")

		do
		{
		  pokemonList = try managedContext.fetch(fetchRequest)
		}
		catch let error as NSError
		{
		  print("Could not fetch. \(error), \(error.userInfo)")
		}
		
		return pokemonList
	}

	func populate()
	{
		let genText = "allGens"
		let list = txtReader.linesFromResourceForced(textFile: genText)

		var count = 0
		
		for pokemon in list
		{
			dispatchGroup.enter()
			let pokemonToSave = NSManagedObject(entity: entity, insertInto: managedContext)
			
			do
			{
			  try managedContext.save()
			  pokemonList.append(pokemonToSave)
			}
			catch let error as NSError
			{
			  print("Could not save. \(error), \(error.userInfo)")
			}
			
			pokemonToSave.setValue(pokemon, forKey: "name")
			pokemonToSave.setValue(count, forKey: "number")
			pokemonToSave.setValue(0, forKey: "encounters")
			pokemonToSave.setValue("Not Caught", forKey: "caughtDescription")
			pokemonToSave.setValue("none", forKey: "caughtBall")
			
			savePokemon(pokemon: pokemonToSave)
			
			dispatchGroup.leave()
			count += 1
		}
	}
	
	func savePokemon(pokemon: NSManagedObject)
	{
		do
		{
			try managedContext.save()
		}
		catch let error as NSError
		{
			print("Could not save \(pokemon.value(forKey: "name")). \(error.localizedDescription)")
		}
	}
	
	func deleteAll()
	{
		for pokemon in pokemonList
		{
			managedContext.delete(pokemon)
		}
	}
}
