//
//  ColorService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 05/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class ColorService
{
	fileprivate var colorRepository = ColorRepository()

	func getPrimaryColor() -> UIColor
	{
		return UIColor(netHex: colorRepository.primaryColor)
	}

	func getSecondaryColor() -> UIColor
	{
		return UIColor(netHex: colorRepository.secondaryColor)
	}

	func getTertiaryColor() -> UIColor
	{
		return UIColor(netHex: colorRepository.tertiaryColor)
	}

	func save(hex: Int, name: String)
	{
		colorRepository.save(hex: hex, name: name)
	}

	func setPrimaryColor(primaryColor: Int)
	{
		colorRepository.primaryColor = primaryColor
	}

	func setSecondaryColor(secondaryColor: Int)
	{
		colorRepository.secondaryColor = secondaryColor
	}

	func setTertiaryColor(tertiaryColor: Int)
	{
		colorRepository.tertiaryColor = tertiaryColor
	}

	func getPrimaryHex() -> Int
	{
		return colorRepository.primaryColor
	}

	func getSecondaryHex() -> Int
	{
		return colorRepository.secondaryColor
	}

	func getTertiaryHex() -> Int
	{
		return colorRepository.tertiaryColor
	}
}
