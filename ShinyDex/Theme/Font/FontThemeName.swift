import Foundation

enum FontThemeName : CustomStringConvertible {
	case Retro
	case Modern
	var description: String {
		switch self {
			case .Retro: return "Retro"
			case .Modern: return "Modern"
		}
	}
}
