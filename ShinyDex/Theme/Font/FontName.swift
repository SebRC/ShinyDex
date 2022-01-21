import Foundation

enum FontName : CustomStringConvertible {
	case PokemonGB
	var description : String {
		switch self {
			case .PokemonGB: return "PokemonGB"
		}
	}
}
