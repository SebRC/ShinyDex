import Foundation
import UIKit

class FontSettingsRepository {
	fileprivate let defaults = UserDefaults.standard

	func getFontThemeName() -> String {
		if let loadedFontThemeName = defaults.string(forKey: "fontTheme") as String? {
			return loadedFontThemeName
		}
		return FontThemeName.Retro.description
	}

	func getXxSmallFontSize() -> CGFloat {
		return CGFloat(defaults.float(forKey: "xxSmallFontSize"))
	}

	func getExtraSmallFontSize() -> CGFloat {
		return CGFloat(defaults.float(forKey: "extraSmallFontSize"))
	}

	func getSmallFontSize() -> CGFloat {
		return CGFloat(defaults.float(forKey: "smallFontSize"))
	}

	func getMediumFontSize() -> CGFloat {
		return CGFloat(defaults.float(forKey: "mediumFontSize"))
	}

	func getLargeFontSize() -> CGFloat {
		return CGFloat(defaults.float(forKey: "largeFontSize"))
	}

	func getExtraLargeFontSize() -> CGFloat {
		return CGFloat(defaults.float(forKey: "extraLargeFontSize"))
	}

	func getXxLargeFontSize() -> CGFloat {
		return CGFloat(defaults.float(forKey: "xxLargeFontSize"))
	}

	func save(fontThemeName: String) {
		let isModernTheme = fontThemeName == FontThemeName.Modern.description
		defaults.set(fontThemeName, forKey: "fontTheme")
		defaults.set(isModernTheme ? 12 : 7, forKey: "xxSmallFontSize")
		defaults.set(isModernTheme ? 15 : 10, forKey: "extraSmallFontSize")
		defaults.set(isModernTheme ? 17 : 12, forKey: "smallFontSize")
		defaults.set(isModernTheme ? 20 : 15, forKey: "mediumFontSize")
		defaults.set(isModernTheme ? 22 : 17, forKey: "largeFontSize")
		defaults.set(isModernTheme ? 25 : 20, forKey: "extraLargeFontSize")
		defaults.set(isModernTheme ? 27 : 22, forKey: "xxLargeFontSize")
	}
}
