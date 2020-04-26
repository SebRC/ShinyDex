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
	var names: [String]
	var pokemon: [Pokemon]

	init(huntEntity: NSManagedObject)
	{
		self.huntEntity = huntEntity
		self.name = huntEntity.value(forKey: "name") as! String
		self.names = huntEntity.value(forKey: "names") as! [String]
		self.pokemon = [Pokemon]()
	}

	init(name: String, pokemon: [Pokemon])
	{
		self.name = name
		self.names = [String]()
		self.pokemon = pokemon
	}
}
