//
//  Hunt.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 22/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import CoreData

class Hunt
{
	var huntEntity: NSManagedObject?
	var name: String
	var indexes: [Int]
	var pokemon: [Pokemon]
	var totalEncounters: Int

	init(huntEntity: NSManagedObject)
	{
		self.huntEntity = huntEntity
		self.name = huntEntity.value(forKey: "name") as! String
		self.indexes = huntEntity.value(forKey: "indexes") as! [Int]
		self.pokemon = [Pokemon]()
		self.totalEncounters = 0
	}

	init(name: String, pokemon: [Pokemon])
	{
		self.name = name
		self.indexes = [Int]()
		self.pokemon = pokemon
		self.totalEncounters = 0
	}
}
