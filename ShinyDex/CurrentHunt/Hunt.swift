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
	var pokemon: [Pokemon]

	init(huntEntity: NSManagedObject)
	{
		self.huntEntity = huntEntity
		self.name = huntEntity.value(forKey: "name") as! String
		pokemon = huntEntity.value(forKey: "pokemon") as! [Pokemon]
	}

	init(name: String, pokemon: [Pokemon])
	{
		self.name = name
		self.pokemon = pokemon
	}
}
