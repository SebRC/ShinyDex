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
	fileprivate let defaults = UserDefaults.standard

	func save(names: [String])
	{
		defaults.set(names, forKey: "currentHunt")
	}

	func getCurrenHuntNames() -> [String]
	{
		if let loadedHuntNames = defaults.array(forKey: "currentHunt") as? [String]
		{
			return loadedHuntNames
		}
		return [String]()
	}
}
