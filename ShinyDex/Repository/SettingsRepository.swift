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
	var isShinyCharmActive: Bool
	var isLureInUse: Bool
	var generation: Int
	var shinyOdds: Int?

	static let settingsRepositorySingleton = SettingsRepository()
	fileprivate let oddsService = OddsService()
	
	let defaults = UserDefaults.standard
	
	fileprivate init()
	{
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
		defaults.set(isShinyCharmActive, forKey: "isShinyCharmActive")
		defaults.set(isLureInUse, forKey: "isLureInUse")
		defaults.set(generation, forKey: "generation")
	}
	
	func loadSettings()
	{
		loadIsShinyCharmActive()

		loadIsLureInUse()
		
		loadGeneration()
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
}
