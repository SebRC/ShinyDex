//
//  FontSettingsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 04/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class FontSettingsService
{
	var xxSmallFontSize: CGFloat
	var extraSmallFontSize: CGFloat
	var smallFontSize: CGFloat
	var mediumFontSize: CGFloat
	var largeFontSize: CGFloat
	var extraLargeFontSize: CGFloat
	var xxLargeFontSize: CGFloat
	var fontSettingsRepository = FontSettingsRepository()
	var colorService = ColorService()
	var fontTheme: String?
	var retroFontName = "PokemonGB"

	init()
	{
		xxSmallFontSize = 12.0
		extraSmallFontSize = 15.0
		smallFontSize = 17.0
		mediumFontSize = 20.0
		largeFontSize = 22.0
		extraLargeFontSize = 25.0
		xxLargeFontSize = 27.0
		fontSettingsRepository.load()
		fontTheme = fontSettingsRepository.fontTheme
		setFont()
	}

	func setFont()
	{
		let isModernTheme = fontTheme == "Modern"
		xxSmallFontSize = isModernTheme ? 12.0 : 7
		extraSmallFontSize = isModernTheme ? 15.0 : 10
		smallFontSize = isModernTheme ? 17.0 : 12
		mediumFontSize = isModernTheme ? 20.0 : 15
		largeFontSize = isModernTheme ? 22.0 : 17
		extraLargeFontSize = isModernTheme ? 25.0 : 20
		xxLargeFontSize = isModernTheme ? 27.0 : 22
	}

	// TODO: should use tertiary color
	func getFontAsNSAttibutedStringKey(fontSize: CGFloat) -> AnyHashable
	{
		if fontTheme == "Modern"
		{
			return [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize),
					NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]
		}
		return [NSAttributedString.Key.font : UIFont(name: "PokemonGB", size: fontSize)!,
				NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]
	}

	func getXxSmallFont() -> UIFont
	{
		return getFont(fontSize: xxSmallFontSize)
	}

	func getExtraSmallFont() -> UIFont
	{
		return getFont(fontSize: extraSmallFontSize)
	}

	func getSmallFont() -> UIFont
	{
		return getFont(fontSize: smallFontSize)
	}

	func getMediumFont() -> UIFont
	{
		return getFont(fontSize: mediumFontSize)
	}

	func getLargeFont() -> UIFont
	{
		return getFont(fontSize: largeFontSize)
	}

	func getExtraLargeFont() -> UIFont
	{
		return getFont(fontSize: extraLargeFontSize)
	}

	func getXxLargeFont() -> UIFont
	{
		return getFont(fontSize: xxLargeFontSize)
	}

	fileprivate func getFont(fontSize: CGFloat) -> UIFont
	{
		let fontThemeIsModern = fontTheme == "Modern"

		return (fontThemeIsModern ? UIFont.systemFont(ofSize: fontSize) : UIFont(name: retroFontName, size: fontSize))!
	}

	func setFont(selectedSegment: Int)
	{
		let fontThemeIsModern = selectedSegment == 0
		fontTheme = fontThemeIsModern ? "Modern" : "Retro"
		setFont()
	}

	func save()
	{
		fontSettingsRepository.save(fontTheme: fontTheme!)
	}
}
