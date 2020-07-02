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
	var isLureInUse: Bool
	var isMasudaHunting: Bool
	var shinyOdds: Int
	var huntMethod: HuntMethod

	init(_ generation: Int, _ isShinyCharmActive: Bool, _ isLureInUse: Bool, _ isMasudaHunting: Bool, _ huntMethod: HuntMethod, _ shinyOdds: Int = 8192)
	{
		self.generation = generation
		self.isShinyCharmActive = isShinyCharmActive
		self.isLureInUse = isLureInUse
		self.isMasudaHunting = isMasudaHunting
		self.huntMethod = huntMethod
		self.shinyOdds = shinyOdds
	}
}
