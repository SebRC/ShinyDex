//
//  FontThemeName.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 13/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

enum FontThemeName : CustomStringConvertible
{
	case Retro
	case Modern

	var description: String
	{
		switch self
		{
		case .Retro: return "Retro"
		case .Modern: return "Modern"
		}
	}
}
