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
		defaults.set(hex == 0 ? hex + 1 : hex, forKey: name)
	}

	func getPrimaryColor() -> UIColor
	{
		if let loadedPrimaryColor = defaults.integer(forKey: "primaryColor") as Int?
		{
			return loadedPrimaryColor == 0 ? UIColor(netHex: 0xABE8ED) : UIColor(netHex: loadedPrimaryColor)
		}
	}

	func getSecondaryColor() -> UIColor
	{
		if let loadedSecondaryColor = defaults.integer(forKey: "secondaryColor") as Int?
		{
			return loadedSecondaryColor == 0 ? UIColor(netHex: 0x86BFE4) : UIColor(netHex: loadedSecondaryColor)
		}
	}

	func getTertiaryColor() -> UIColor
	{
		if let loadedTertiaryColor = defaults.integer(forKey: "tertiaryColor") as Int?
		{
			return loadedTertiaryColor == 0 ? UIColor(netHex: 0xFFFFFF) : UIColor(netHex: loadedTertiaryColor)
		}
	}

	func getPrimaryHex() -> Int
	{
		if let loadedPrimaryHex = defaults.integer(forKey: "primaryColor") as Int?
		{
			return loadedPrimaryHex == 0 ? 0xABE8ED : loadedPrimaryHex
		}
	}

	func getSecondaryHex() -> Int
	{
		if let loadedSecondaryHex = defaults.integer(forKey: "secondaryColor") as Int?
		{
			return loadedSecondaryHex == 0 ? 0x03C4FB : loadedSecondaryHex
		}
	}

	func getTertiaryHex() -> Int
	{
		if let loadedTertiaryHex = defaults.integer(forKey: "tertiaryColor") as Int?
		{
			return loadedTertiaryHex == 0 ? 0xFFFFFF : loadedTertiaryHex
		}
	}
}
