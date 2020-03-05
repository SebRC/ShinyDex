//
//  FontSettingsRepository.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 04/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class FontSettingsRepository
{
	var fontTheme: String?
	let defaults = UserDefaults.standard

	func load()
	{
		if let loadedFontTheme = defaults.string(forKey: "fontTheme") as String?
		{
			fontTheme = loadedFontTheme
		}
		else
		{
			fontTheme = "Retro"
		}
	}

	func save(fontTheme: String)
	{
		defaults.set(fontTheme, forKey: "fontTheme")
	}
}
