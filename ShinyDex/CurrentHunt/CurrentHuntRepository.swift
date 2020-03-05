//
//  CurrentHuntRepository.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/10/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation

class CurrentHuntRepository
{
	fileprivate var currentHuntNames = [String]()
	fileprivate let defaults = UserDefaults.standard

	init()
	{
		load()
	}

	func save(names: [String])
	{
		defaults.set(names, forKey: "currentHunt")
	}
	
	fileprivate func load()
	{
		if let loadedHuntNames = defaults.array(forKey: "currentHunt") as? [String]
		{
			currentHuntNames = loadedHuntNames
		}
	}

	func getCurrenHuntNames() -> [String]
	{
		return currentHuntNames
	}
}
