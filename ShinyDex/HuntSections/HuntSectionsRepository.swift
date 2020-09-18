//
//  HuntSectionsRepository.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 21/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation

class HuntSectionsRepository
{
	fileprivate let defaults = UserDefaults.standard

	func get() -> HuntSections
	{
		var collapsedSections = Set<Int>()
		if let loadedCollapsedSections = defaults.array(forKey: "collapsedSections")
		{
			collapsedSections = Set(loadedCollapsedSections.map { $0 as! Int })
		}
		return HuntSections(collapsedSections: collapsedSections)
	}

	func save(_ huntSections: HuntSections)
	{
		defaults.set(Array(huntSections.collapsedSections), forKey: "collapsedSections")
	}
}
