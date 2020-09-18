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
	var collapsedSections: Set<Int>

	init(collapsedSections: Set<Int>)
	{
		self.collapsedSections = collapsedSections
	}
}
