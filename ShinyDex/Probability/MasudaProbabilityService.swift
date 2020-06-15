//
//  MasudaProbabilityService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/05/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class MasudaProbabilityService
{
	func getProbability(eggsHatched: Int, odds: Int) -> Double
	{
		return Double.getProbability(encounters: eggsHatched, odds: odds)
	}
}
