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
	var generation: Int
	var shinyOdds: Int?
	var fontColorHex: Int
	var fontName: String
	var fontTheme: String
	var xxSmallFontSize: CGFloat
	var extraSmallFontSize: CGFloat
	var smallFontSize: CGFloat
	var mediumFontSize: CGFloat
	var largeFontSize: CGFloat
	var extraLargeFontSize: CGFloat
	var xxLargeFontSize: CGFloat

	static let settingsRepositorySingleton = SettingsRepository()
	
	let defaults = UserDefaults.standard
	
	fileprivate init()
	{
		primaryColor = 0xABE8ED
		secondaryColor = 0x03C4FB
		tertiaryColor = 0xFFFFFF
		isShinyCharmActive = false
		generation = 0
		fontColorHex = 0xffffff
		fontName = "PokemonGB"
		fontTheme = "Retro"
		xxSmallFontSize = 12.0
		extraSmallFontSize = 15.0
		smallFontSize = 17.0
		mediumFontSize = 20.0
		largeFontSize = 22.0
		extraLargeFontSize = 25.0
		xxLargeFontSize = 27.0
		
		loadSettings()
		
		setShinyOdds()
	}
	
	func setShinyOdds()
	{
		shinyOdds = getShinyOdds(currentGen: generation, isCharmActive: isShinyCharmActive)
	}
	
	func getShinyOdds(currentGen: Int, isCharmActive: Bool) -> Int
	{
		if currentGen <= 3
		{
			return 8192
		}
		else if currentGen == 4 && !isCharmActive
		{
			return 8192
		}
		else if currentGen == 4
		{
			return 2731
		}
		else if currentGen > 4 && !isCharmActive
		{
			return 4096
		}
		else
		{
			return 1365
		}
	}
	
	func saveSettings()
	{
		defaults.set(primaryColor, forKey: "primaryColor")
		defaults.set(secondaryColor, forKey: "secondaryColor")
		defaults.set(tertiaryColor, forKey: "tertiaryColor")
		defaults.set(isShinyCharmActive, forKey: "isShinyCharmActive")
		defaults.set(generation, forKey: "generation")
		defaults.set(fontColorHex, forKey: "fontColorHex")
		defaults.set(fontTheme, forKey: "fontTheme")
	}
	
	func loadSettings()
	{
		loadPrimaryColor()
		
		loadSecondaryColor()
		
		loadTertiaryColor()
		
		loadIsShinyCharmActive()
		
		loadGeneration()
		
		loadHexFontColor()
		
		loadFontTheme()
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
	
	fileprivate func loadGeneration()
	{
		if let loadedGeneration = defaults.integer(forKey: "generation") as Int?
		{
			generation = loadedGeneration
		}
	}
	
	fileprivate func loadHexFontColor()
	{
		if let loadedHexFontColor = defaults.integer(forKey: "fontColorHex") as Int?
		{
			fontColorHex = loadedHexFontColor
		}
	}
	
	fileprivate func loadFontTheme()
	{
		if let loadedFontTheme = defaults.string(forKey: "fontTheme") as String?
		{
			fontTheme = loadedFontTheme
			
			if fontTheme == "Modern"
			{
				setModernFont()
			}
			else
			{
				setRetroFont()
			}
		}
	}
	
	func changeIsShinyCharmActive(isSwitchOn: Bool)
	{
		isShinyCharmActive = isSwitchOn
		
		saveSettings()
	}
	
	func setGlobalFont(selectedSegment: Int)
	{
		if selectedSegment == 0
		{
			fontTheme = "Modern"
			setModernFont()
		}
		else
		{
			fontTheme = "Retro"
			setRetroFont()
		}
		
		saveSettings()
	}
	
	func getFontAsNSAttibutedStringKey(fontSize: CGFloat) -> AnyHashable
	{
		if fontTheme == "Modern"
		{
			return [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize),
					NSAttributedString.Key.foregroundColor: getTertiaryColor()]
		}
		return [NSAttributedString.Key.font : UIFont(name: "PokemonGB", size: fontSize)!,
		NSAttributedString.Key.foregroundColor: getTertiaryColor()]
	}
	
	func setModernFont()
	{
		xxSmallFontSize = 12.0
		extraSmallFontSize = 15.0
		smallFontSize = 17.0
		mediumFontSize = 20.0
		largeFontSize = 22.0
		extraLargeFontSize = 25.0
		xxLargeFontSize = 27.0
	}
	
	func setRetroFont()
	{
		xxSmallFontSize = 7.0
		extraSmallFontSize = 10.0
		smallFontSize = 12.0
		mediumFontSize = 15.0
		largeFontSize = 17.0
		extraLargeFontSize = 20.0
		xxLargeFontSize = 22.0
	}
	
	func getXxSmallFont() -> UIFont
	{
		let xxSmallFont = getFont(fontSize: xxSmallFontSize)
		
		return xxSmallFont
	}
	
	func getExtraSmallFont() -> UIFont
	{
		let extraSmallFont = getFont(fontSize: extraSmallFontSize)
		
		return extraSmallFont
	}
	
	func getSmallFont() -> UIFont
	{
		let smallFont = getFont(fontSize: smallFontSize)
		
		return smallFont
	}
	
	func getMediumFont() -> UIFont
	{
		let mediumFont = getFont(fontSize: mediumFontSize)
		
		return mediumFont
	}
	
	func getLargeFont() -> UIFont
	{
		let largeFont = getFont(fontSize: largeFontSize)
		
		return largeFont
	}
	
	func getExtraLargeFont() -> UIFont
	{
		let extraLargeFont = getFont(fontSize: extraLargeFontSize)
		
		return extraLargeFont
	}
	
	func getXxLargeFont() -> UIFont
	{
		let xxLargeFont = getFont(fontSize: xxLargeFontSize)
		
		return xxLargeFont
	}
	
	fileprivate func getFont(fontSize: CGFloat) -> UIFont
	{
		let fontThemeIsModern = fontTheme == "Modern"
		
		if fontThemeIsModern
		{
			return UIFont.systemFont(ofSize: fontSize)
		}
		
		return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
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
