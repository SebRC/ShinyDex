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
		var huntMethod = HuntMethod.Encounters
		var increment = 1
		var collapsedSections = Set<Int>()
		if let loadedGeneration = defaults.integer(forKey: "generation") as Int?
		{
			generation = loadedGeneration
		}
		if let loadedIsShinyCharmActive = defaults.bool(forKey: "isShinyCharmActive") as Bool?
		{
			isShinyCharmActive = loadedIsShinyCharmActive
		}
		if let loadedHuntMethod = defaults.string(forKey: "huntMethod") as String?
		{
			huntMethod = HuntMethod(rawValue: loadedHuntMethod)!
		}
		if let loadedIncrement = defaults.integer(forKey: "increment") as Int?
		{
			increment = loadedIncrement == 0 ? 1 : loadedIncrement
		}
		if let loadedCollapsedSections = defaults.array(forKey: "collapsedSections")
		{
			collapsedSections = Set(loadedCollapsedSections.map { $0 as! Int })
		}
		return HuntState(generation: generation, isShinyCharmActive: isShinyCharmActive, huntMethod: huntMethod, increment: increment, collapsedSections: collapsedSections)
	}

	func save(_ huntState: HuntState)
	{
		defaults.set(huntState.generation, forKey: "generation")
		defaults.set(huntState.isShinyCharmActive, forKey: "isShinyCharmActive")
		defaults.set(huntState.huntMethod.rawValue, forKey: "huntMethod")
		defaults.set(huntState.increment, forKey: "increment")
		defaults.set(Array(huntState.collapsedSections), forKey: "collapsedSections")
	}
}
