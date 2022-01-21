import Foundation
import UIKit

class ColorService {
	fileprivate var colorRepository = ColorRepository()

	func getPrimaryColor() -> UIColor {
		return colorRepository.getPrimaryColor()
	}

	func getSecondaryColor() -> UIColor {
		return colorRepository.getSecondaryColor()
	}

	func getTertiaryColor() -> UIColor {
		return colorRepository.getTertiaryColor()
	}

	func save(hex: Int, name: String) {
		colorRepository.save(hex: hex, name: name)
	}

	func getPrimaryHex() -> Int {
		return colorRepository.getPrimaryHex()
	}

	func getSecondaryHex() -> Int {
		return colorRepository.getSecondaryHex()
	}

	func getTertiaryHex() -> Int {
		return colorRepository.getTertiaryHex()
	}
}
