//
//  Pokemon.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Pokemon: NSObject
{
	var pokemonEntity: NSManagedObject
	var name: String
	var number: Int
	var encounters: Int
	var caughtDescription: String
	var caughtBall: String
	var isBeingHunted: Bool
	var shinyImage: UIImage?
	var shinyGifData: Data

	init(pokemonEntity: NSManagedObject)
	{
		self.pokemonEntity = pokemonEntity
		self.name = pokemonEntity.value(forKey: "name") as! String
		self.number = pokemonEntity.value(forKey: "number") as! Int
		self.caughtDescription = pokemonEntity.value(forKey: "caughtDescription") as! String
		self.encounters = pokemonEntity.value(forKey: "encounters") as! Int
		self.isBeingHunted = pokemonEntity.value(forKey: "isBeingHunted") as? Bool ?? false
		self.caughtBall = pokemonEntity.value(forKey: "caughtBall") as! String
		self.shinyImage = UIImage(named: name.lowercased())

		if let shinyGifAsset = NSDataAsset(name: name)
		{
			let data = shinyGifAsset.data
			self.shinyGifData = data
		}
		else
		{
			self.shinyGifData = Data()
		}
	}
}
