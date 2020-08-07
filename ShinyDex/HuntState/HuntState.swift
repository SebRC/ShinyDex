//
//  HuntState.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 24/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class HuntState
{
	var generation: Int
	var isShinyCharmActive: Bool
	var shinyOdds: Int
	var huntMethod: HuntMethod
	var increment: Int
	var collapsedSections: Set<Int>

	init(generation: Int, isShinyCharmActive: Bool, huntMethod: HuntMethod, increment: Int, collapsedSections: Set<Int>, shinyOdds: Int = 8192)
	{
		self.generation = generation
		self.isShinyCharmActive = isShinyCharmActive
		self.huntMethod = huntMethod
		self.increment = increment
		self.collapsedSections = collapsedSections
		self.shinyOdds = shinyOdds
	}
}
