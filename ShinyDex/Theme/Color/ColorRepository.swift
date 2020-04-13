//
//  ColorRepository.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 05/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class ColorRepository
{
	fileprivate let defaults = UserDefaults.standard

	func save(hex: Int, name: String)
	{
		defaults.set(hex, forKey: name)
	}

	func getPrimaryColor() -> UIColor
	{
		if let loadedPrimaryColor = defaults.integer(forKey: "primaryColor") as Int?
		{
			return UIColor(netHex: loadedPrimaryColor)
		}
		return UIColor(netHex: 0xABE8ED)
	}

	func getSecondaryColor() -> UIColor
	{
		if let loadedSecondaryColor = defaults.integer(forKey: "secondaryColor") as Int?
		{
			return UIColor(netHex: loadedSecondaryColor)
		}
		return UIColor(netHex: 0x03C4FB)
	}

	func getTertiaryColor() -> UIColor
	{
		if let loadedTertiaryColor = defaults.integer(forKey: "tertiaryColor") as Int?
		{
			return UIColor(netHex: loadedTertiaryColor)
		}
		return UIColor(netHex: 0xFFFFFF)
	}

	func getPrimaryHex() -> Int
	{
		if let loadedPrimaryHex = defaults.integer(forKey: "primaryColor") as Int?
		{
			return loadedPrimaryHex
		}
		return 0xABE8ED
	}

	func getSecondaryHex() -> Int
	{
		if let loadedSecondaryHex = defaults.integer(forKey: "secondaryColor") as Int?
		{
			return loadedSecondaryHex
		}
		return 0x03C4FB
	}

	func getTertiaryHex() -> Int
	{
		if let loadedTertiaryHex = defaults.integer(forKey: "tertiaryColor") as Int?
		{
			return loadedTertiaryHex
		}
		return 0xFFFFFF
	}
}
