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
	fileprivate let defaults = UserDefaults.standard

	func get() -> HuntState
	{
		var generation = 0
		var isShinyCharmActive = false
		var isLureInUse = false
		var isMasudaHunting = false
		var huntMethod = HuntMethod.Encounters
		if let loadedGeneration = defaults.integer(forKey: "generation") as Int?
		{
			generation = loadedGeneration
		}
		if let loadedIsShinyCharmActive = defaults.bool(forKey: "isShinyCharmActive") as Bool?
		{
			isShinyCharmActive = loadedIsShinyCharmActive
		}
		if let loadedisLureInUse = defaults.bool(forKey: "isLureInUse") as Bool?
		{
			isLureInUse = loadedisLureInUse
		}
		if let loadedIsMasudaHunting = defaults.bool(forKey: "isMasudaHunting") as Bool?
		{
			isMasudaHunting = loadedIsMasudaHunting
		}
		if let loadedHuntMethod = defaults.string(forKey: "huntMethod") as String?
		{
			huntMethod = HuntMethod(rawValue: loadedHuntMethod)!
		}
		return HuntState(generation, isShinyCharmActive, isLureInUse, isMasudaHunting, huntMethod)
	}

	func save(_ huntState: HuntState)
	{
		defaults.set(huntState.generation, forKey: "generation")
		defaults.set(huntState.isShinyCharmActive, forKey: "isShinyCharmActive")
		defaults.set(huntState.isLureInUse, forKey: "isLureInUse")
		defaults.set(huntState.isMasudaHunting, forKey: "isMasudaHunting")
		defaults.set(huntState.huntMethod.rawValue, forKey: "huntMethod")
	}
}
