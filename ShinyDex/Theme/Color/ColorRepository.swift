//
//  ColorRepository.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 05/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class ColorRepository {
	fileprivate let defaults = UserDefaults.standard
	fileprivate let primaryHex = 0xFFB30A
	fileprivate let secondaryHex = 0xFBC118
	fileprivate let tertiaryHex = 0xFFFFCA


	func save(hex: Int, name: String) {
		defaults.set(hex == 0 ? hex + 1 : hex, forKey: name)
	}

	func getPrimaryColor() -> UIColor {
		if let loadedPrimaryColor = defaults.integer(forKey: "primaryColor") as Int? {
			return loadedPrimaryColor == 0 ? UIColor(netHex: primaryHex) : UIColor(netHex: loadedPrimaryColor)
		}
	}

	func getSecondaryColor() -> UIColor {
		if let loadedSecondaryColor = defaults.integer(forKey: "secondaryColor") as Int? {
			return loadedSecondaryColor == 0 ? UIColor(netHex: secondaryHex) : UIColor(netHex: loadedSecondaryColor)
		}
	}

	func getTertiaryColor() -> UIColor {
		if let loadedTertiaryColor = defaults.integer(forKey: "tertiaryColor") as Int? {
			return loadedTertiaryColor == 0 ? UIColor(netHex: tertiaryHex) : UIColor(netHex: loadedTertiaryColor)
		}
	}

	func getPrimaryHex() -> Int {
		if let loadedPrimaryHex = defaults.integer(forKey: "primaryColor") as Int? {
			return loadedPrimaryHex == 0 ? primaryHex : loadedPrimaryHex
		}
	}

	func getSecondaryHex() -> Int {
		if let loadedSecondaryHex = defaults.integer(forKey: "secondaryColor") as Int? {
			return loadedSecondaryHex == 0 ? secondaryHex : loadedSecondaryHex
		}
	}

	func getTertiaryHex() -> Int {
		if let loadedTertiaryHex = defaults.integer(forKey: "tertiaryColor") as Int? {
			return loadedTertiaryHex == 0 ? tertiaryHex : loadedTertiaryHex
		}
	}
}
