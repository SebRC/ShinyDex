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
	var primaryColor: Int
	var secondaryColor: Int
	var tertiaryColor: Int

	fileprivate let defaults = UserDefaults.standard

	init()
	{
		primaryColor = 0xABE8ED
		secondaryColor = 0x03C4FB
		tertiaryColor = 0xFFFFFF

		load()
	}

	func saveAll()
	{
		defaults.set(primaryColor, forKey: "primaryColor")
		defaults.set(secondaryColor, forKey: "secondaryColor")
		defaults.set(tertiaryColor, forKey: "tertiaryColor")
	}

	func save(hex: Int, name: String)
	{
		defaults.set(hex, forKey: name)
	}

	fileprivate func load()
	{
		loadPrimaryColor()

		loadSecondaryColor()

		loadTertiaryColor()
	}

	fileprivate func loadPrimaryColor()
	{
		if let loadedPrimaryColor = defaults.integer(forKey: "primaryColor") as Int?
		{
			primaryColor = loadedPrimaryColor
		}

		let primaryColorIsLoaded = primaryColor != 0

		if !primaryColorIsLoaded
		{
			primaryColor = 0xABE8ED
		}
	}

	fileprivate func loadSecondaryColor()
	{
		if let loadedSecondaryColor = defaults.integer(forKey: "secondaryColor") as Int?
		{
			secondaryColor = loadedSecondaryColor
		}

		let secondaryColorIsLoaded = secondaryColor != 0

		if !secondaryColorIsLoaded
		{
			secondaryColor = 0x03C4FB
		}
	}

	fileprivate func loadTertiaryColor()
	{
		if let loadedTertiaryColor = defaults.integer(forKey: "tertiaryColor") as Int?
		{
			tertiaryColor = loadedTertiaryColor
		}

		let tertiaryColorIsLoaded = tertiaryColor != 0

		if !tertiaryColorIsLoaded
		{
			tertiaryColor = 0xFFFFFF
		}
	}
}
