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
	fileprivate var fontSettingsRepository = FontSettingsRepository()
	fileprivate var colorService = ColorService()

	func getFontAsNSAttibutedStringKey(fontSize: CGFloat) -> AnyHashable
	{
		return [NSAttributedString.Key.font : getFont(fontSize: fontSize),
		NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]
	}

	func getFontThemeName() -> String
	{
		return fontSettingsRepository.getFontThemeName()
	}

	func getXxSmallFont() -> UIFont
	{
		return getFont(fontSize: fontSettingsRepository.getXxSmallFontSize())
	}

	func getExtraSmallFont() -> UIFont
	{
		return getFont(fontSize: fontSettingsRepository.getExtraSmallFontSize())
	}

	func getSmallFont() -> UIFont
	{
		return getFont(fontSize: fontSettingsRepository.getSmallFontSize())
	}

	func getMediumFont() -> UIFont
	{
		return getFont(fontSize: fontSettingsRepository.getMediumFontSize())
	}

	func getLargeFont() -> UIFont
	{
		return getFont(fontSize: fontSettingsRepository.getLargeFontSize())
	}

	func getExtraLargeFont() -> UIFont
	{
		return getFont(fontSize: fontSettingsRepository.getExtraLargeFontSize())
	}

	func getXxLargeFont() -> UIFont
	{
		return getFont(fontSize: fontSettingsRepository.getXxLargeFontSize())
	}

	fileprivate func getFont(fontSize: CGFloat) -> UIFont
	{
		let fontThemeIsModern = fontSettingsRepository.getFontThemeName() == FontThemeName.Modern.description

		return (fontThemeIsModern ? UIFont.systemFont(ofSize: fontSize) : UIFont(name: FontName.PokemonGB.description, size: fontSize))!
	}

	func save(fontThemeName: String)
	{
		fontSettingsRepository.save(fontThemeName: fontThemeName)
	}
}
