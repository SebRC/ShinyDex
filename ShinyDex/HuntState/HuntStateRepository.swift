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
		var collapsedSections = Set<Int>()
		if let loadedCollapsedSections = defaults.array(forKey: "collapsedSections")
		{
			collapsedSections = Set(loadedCollapsedSections.map { $0 as! Int })
		}
		return HuntState(collapsedSections: collapsedSections)
	}

	func save(_ huntState: HuntState)
	{
		defaults.set(Array(huntState.collapsedSections), forKey: "collapsedSections")
	}
}
