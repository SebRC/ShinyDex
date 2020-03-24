//
//  HuntStateRepository.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 21/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation

class HuntStateRepository
{
	var generation: Int
	var isShinyCharmActive: Bool
	var isLureInUse: Bool
	
	let defaults = UserDefaults.standard
	
	init()
	{
		isShinyCharmActive = false
		isLureInUse = false
		generation = 0
		
		load()
	}

	func load()
	{
		loadIsShinyCharmActive()
		loadIsLureInUse()
		loadGeneration()
	}

	func save(generation: Int, isShinyCharmActive: Bool, isLureInUse: Bool)
	{
		defaults.set(generation, forKey: "generation")
		defaults.set(isShinyCharmActive, forKey: "isShinyCharmActive")
		defaults.set(isLureInUse, forKey: "isLureInUse")
	}

	fileprivate func loadGeneration()
	{
		if let loadedGeneration = defaults.integer(forKey: "generation") as Int?
		{
			generation = loadedGeneration
		}
	}

	fileprivate func loadIsShinyCharmActive()
	{
		if let loadedIsShinyCharmActive = defaults.bool(forKey: "isShinyCharmActive") as Bool?
		{
			isShinyCharmActive = loadedIsShinyCharmActive
		}
	}

	fileprivate func loadIsLureInUse()
	{
		if let loadedisLureInUse = defaults.bool(forKey: "isLureInUse") as Bool?
		{
			isLureInUse = loadedisLureInUse
		}
	}
}
