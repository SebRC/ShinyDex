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
		else if gen == 2
		{
			return "Hoenn"
		}
		else if gen == 3
		{
			return "Sinnoh"
		}
		else if gen == 4
		{
			return "Unova"
		}
		else if gen == 5
		{
			return "Kalos"
		}
		else if gen == 6
		{
			return "Alola"
		}
		else if gen == 7
		{
			return "Galar"
		}
		else if gen == 8
		{
			return "Hunts"
		}
		return "Kanto"
	}
}
