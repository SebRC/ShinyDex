//
//  Resolver.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 17/03/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class Resolver
{	
	func resolveCounter(generation: Int) -> Int
	{
		if generation == 1
		{
			return 151
		}
		if generation == 2
		{
			return 251
		}
		if generation == 3
		{
			return 386
		}
		if generation == 4
		{
			return 493
		}
		if generation == 5
		{
			return 649
		}
		if generation == 6
		{
			return 721
		}
		
		return 0
	}
	
	func resolveButtonAccess(nameList: [String], name: String) -> Bool
	{
		return !nameList.contains(name)
	}
}
