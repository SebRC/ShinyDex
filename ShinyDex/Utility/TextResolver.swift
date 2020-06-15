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
			return "Johto"
		}
		if gen == 2
		{
			return "Hoenn"
		}
		if gen == 3
		{
			return "Sinnoh"
		}
		if gen == 4
		{
			return "Unova"
		}
		if gen == 5
		{
			return "Kalos"
		}
		if gen == 6
		{
			return "Alola"
		}
		if gen == 7
		{
			return "Hunts"
		}
		return "Kanto"
	}
}
