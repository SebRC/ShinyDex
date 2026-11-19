import Foundation

enum Gender: String, CaseIterable {
	case male
	case female
	case genderless

	var name: String {
		switch self {
		case .male: return "Male"
		case .female: return "Female"
		case .genderless: return "Genderless"
		}
	}

	var symbol: String? {
		switch self {
		case .male: return "♂"
		case .female: return "♀"
		case .genderless: return nil
		}
	}
}
