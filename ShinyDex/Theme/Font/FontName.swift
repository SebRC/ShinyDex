//
//  FontName.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 13/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

enum FontName : CustomStringConvertible
{
	case PokemonGB

	var description : String
	{
		switch self
		{
			case .PokemonGB: return "PokemonGB"
		}
	}
}
