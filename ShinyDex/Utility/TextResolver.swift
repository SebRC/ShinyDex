//
//  TextResolver.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/10/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation

class TextResolver
{
	func resolveGenTitle(gen: Int) -> String
	{
		if gen == 1
		{
			return "Gen 2"
		}
		if gen == 2
		{
			return "Gen 3"
		}
		if gen == 3
		{
			return "Gen 4"
		}
		if gen == 4
		{
			return "Gen 5"
		}
		if gen == 5
		{
			return "Gen 6"
		}
		if gen == 6
		{
			return "Gen 7"
		}
		if gen == 7
		{
			return "Current Hunt"
		}
		return "Gen 1"
	}
}
