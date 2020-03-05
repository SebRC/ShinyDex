//
//  SettingsRepository.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 21/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class SettingsRepository
{
	var primaryColor: Int
	var secondaryColor: Int
	var tertiaryColor: Int
	var isShinyCharmActive: Bool
	var isLureInUse: Bool
	var generation: Int
	var shinyOdds: Int?

	static let settingsRepositorySingleton = SettingsRepository()
	fileprivate let oddsService = OddsService()
	
	let defaults = UserDefaults.standard
	
	fileprivate init()
	{
		primaryColor = 0xABE8ED
		secondaryColor = 0x03C4FB
		tertiaryColor = 0xFFFFFF
		isShinyCharmActive = false
		isLureInUse = false
		generation = 0
		
		loadSettings()
		
		setShinyOdds()
	}
	
	func setShinyOdds()
	{
		shinyOdds = oddsService.getShinyOdds(currentGen: generation, isCharmActive: isShinyCharmActive, isLureInUse: isLureInUse, encounters: 0)
	}
	
	func saveSettings()
	{
		defaults.set(primaryColor, forKey: "primaryColor")
		defaults.set(secondaryColor, forKey: "secondaryColor")
		defaults.set(tertiaryColor, forKey: "tertiaryColor")
		defaults.set(isShinyCharmActive, forKey: "isShinyCharmActive")
		defaults.set(isLureInUse, forKey: "isLureInUse")
		defaults.set(generation, forKey: "generation")
	}
	
	func loadSettings()
	{
		loadPrimaryColor()
		
		loadSecondaryColor()
		
		loadTertiaryColor()
		
		loadIsShinyCharmActive()

		loadIsLureInUse()
		
		loadGeneration()
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
	
	fileprivate func loadIsShinyCharmActive()
	{
		if let loadedIsShinyCharmActive = defaults.bool(forKey: "isShinyCharmActive") as Bool?
		{
			isShinyCharmActive = loadedIsShinyCharmActive
		}
	}

	fileprivate func loadIsLureInUse()
	{
		if let loadedisLureInUse = defaults.bool(forKey: "isLureInUse") as Bool?
		{
			isLureInUse = loadedisLureInUse
		}
	}
	
	fileprivate func loadGeneration()
	{
		if let loadedGeneration = defaults.integer(forKey: "generation") as Int?
		{
			generation = loadedGeneration
		}
	}
	
	func changeIsShinyCharmActive(isSwitchOn: Bool)
	{
		isShinyCharmActive = isSwitchOn
		
		saveSettings()
	}

	func changeIsLureInUseActive(isSwitchOn: Bool)
	{
		isLureInUse = isSwitchOn

		saveSettings()
	}
	
	func getPrimaryColor() -> UIColor
	{
		return UIColor(netHex: primaryColor)
	}
	
	func getSecondaryColor() -> UIColor
	{
		return UIColor(netHex: secondaryColor)
	}
	
	func getTertiaryColor() -> UIColor
	{
		return UIColor(netHex: tertiaryColor)
	}
	
	func savePrimaryColor(primaryColor: Int)
	{
		self.primaryColor = primaryColor
		defaults.set(primaryColor, forKey: "primaryColor")
	}
	
	func saveSecondaryColor(secondaryColor: Int)
	{
		self.secondaryColor = secondaryColor
		defaults.set(secondaryColor, forKey: "secondaryColor")
	}
	
	func saveTertiaryColor(tertiaryColor: Int)
	{
		self.tertiaryColor = tertiaryColor
		defaults.set(tertiaryColor, forKey: "tertiaryColor")
	}
}
