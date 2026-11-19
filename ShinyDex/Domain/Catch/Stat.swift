import Foundation

enum Stat: Int, CaseIterable {
	case hp, attack, defense, specialAttack, specialDefense, speed

	var name: String {
		switch self {
		case .hp: return "HP"
		case .attack: return "Attack"
		case .defense: return "Defense"
		case .specialAttack: return "Sp. Atk"
		case .specialDefense: return "Sp. Def"
		case .speed: return "Speed"
		}
	}

	var shortName: String {
		switch self {
		case .hp: return "HP"
		case .attack: return "Atk"
		case .defense: return "Def"
		case .specialAttack: return "SpA"
		case .specialDefense: return "SpD"
		case .speed: return "Spe"
		}
	}
}
